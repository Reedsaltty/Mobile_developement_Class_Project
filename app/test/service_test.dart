import 'package:app/model/SoundEvent.dart';
import 'package:app/service/reminder_service.dart';
import 'package:app/service/sleep_goal_service.dart';
import 'package:app/service/sleep_session_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SleepGoalService goalService;
  late SleepSessionService sessionService;
  late ReminderService reminderService;

  setUp(() {
    goalService = SleepGoalService();
    sessionService = SleepSessionService(goalService); // same goal service
    reminderService = ReminderService(goalService); // shared by both
  });

  group("SleepGoalService", () {
    test("The default goal is 8 hours, waking at 07:00", () {
      expect(goalService.currentGoal.targetGoal, Duration(hours: 8));
      expect(goalService.currentGoal.waketime, Duration(hours: 7));
    });

    test("setGoal saves a valid goal", () {
      goalService.setGoal(
        targetGoal: Duration(hours: 7, minutes: 30),
        wakeTime: Duration(hours: 6, minutes: 30),
      );
      expect(
        goalService.currentGoal.targetGoal,
        Duration(hours: 7, minutes: 30),
      );
    });

    test("3. setGoal rejects a 3-hour goal and keeps the old one", () {
      expect(
        () => goalService.setGoal(
          targetGoal: Duration(hours: 3),
          wakeTime: Duration(hours: 7),
        ),
        throwsException,
      );
      expect(goalService.currentGoal.targetGoal, Duration(hours: 8));
    });
  });

  group("SleepSessionService", () {
    test("startSession uses the current goal", () {
      final session = sessionService.startSession(
        DateTime(2026, 11, 16, 23, 0),
      );
      expect(session.goal, goalService.currentGoal);
      expect(sessionService.currentSession, isNotNull);
    });

    test("4. A second session cannot start while one is running", () {
      sessionService.startSession(DateTime(2026, 11, 16, 23, 0));
      expect(
        () => sessionService.startSession(DateTime(2026, 11, 16, 23, 30)),
        throwsException,
      );
    });

    test("stopSession with nothing running is rejected", () {
      expect(
        () => sessionService.stopSession(DateTime(2026, 11, 17, 7, 0)),
        throwsException,
      );
    });

    test("5. A 29-minute session is discarded", () {
      sessionService.startSession(DateTime(2026, 11, 16, 23, 0));
      final report = sessionService.stopSession(
        DateTime(2026, 11, 16, 23, 29),
      );
      expect(report, isNull);
      expect(sessionService.history.isEmpty, true);
      expect(sessionService.currentSession, isNull);
    });

    test("6. A session of exactly 30 minutes is kept", () {
      sessionService.startSession(DateTime(2026, 11, 16, 23, 0));
      final report = sessionService.stopSession(
        DateTime(2026, 11, 16, 23, 30),
      );
      expect(report, isNotNull);
      expect(sessionService.history.length, 1);
    });

    test("9. The morning report for 23:15 to 06:30", () {
      goalService.setGoal(
        targetGoal: Duration(hours: 8),
        wakeTime: Duration(hours: 6, minutes: 30),
      );
      sessionService.startSession(DateTime(2026, 11, 16, 23, 15));
      final report = sessionService.stopSession(
        DateTime(2026, 11, 17, 6, 30),
      )!;
      expect(report.duration, Duration(hours: 7, minutes: 15));
      expect(report.rating, 91);
      expect(report.bedtimeGap, Duration(minutes: 45));
      expect(report.nightDebt, Duration(minutes: 45));
    });

    test("recordSoundEvent adds the event to the running session", () {
      final session = sessionService.startSession(
        DateTime(2026, 11, 16, 23, 0),
        recordSound: true,
      );
      sessionService.recordSoundEvent(
        Soundevent(
          SoundType.snoring,
          Duration(minutes: 2),
          DateTime(2026, 11, 17, 2, 0),
          0.9,
        ),
      );
      expect(session.events.length, 1);
    });

    test("recordSoundEvent with nothing running is rejected", () {
      expect(
        () => sessionService.recordSoundEvent(
          Soundevent(
            SoundType.snoring,
            Duration(minutes: 2),
            DateTime(2026, 11, 17, 2, 0),
            0.9,
          ),
        ),
        throwsException,
      );
    });

    test("12. With recording off the report has no sound summary", () {
      sessionService.startSession(DateTime(2026, 11, 16, 23, 0));
      final report = sessionService.stopSession(
        DateTime(2026, 11, 17, 7, 0),
      )!;
      expect(report.soundSummary, isNull);
    });

    test("40 minutes of snoring gives a snoring tip", () {
      sessionService.startSession(
        DateTime(2026, 11, 16, 23, 0),
        recordSound: true,
      );
      sessionService.recordSoundEvent(
        Soundevent(
          SoundType.snoring,
          Duration(minutes: 40),
          DateTime(2026, 11, 17, 2, 0),
          0.9,
        ),
      );
      final report = sessionService.stopSession(
        DateTime(2026, 11, 17, 7, 0),
      )!;
      expect(report.soundSummary!.snoring, Duration(minutes: 40));
      expect(report.tip, contains('snored'));
    });

    test("calculateRating returns the session rating", () {
      final session = sessionService.startSession(
        DateTime(2026, 11, 16, 23, 0),
      );
      sessionService.stopSession(DateTime(2026, 11, 17, 5, 0)); // 6 h of an 8 h goal
      expect(sessionService.calculateRating(session), 75);
    });

    test("ratePerceivedQuality saves 1-5 and rejects 6", () {
      final session = sessionService.startSession(
        DateTime(2026, 11, 16, 23, 0),
      );
      sessionService.stopSession(DateTime(2026, 11, 17, 7, 0));
      sessionService.ratePerceivedQuality(session, 4);
      expect(session.perceivedQuality, 4);
      expect(
        () => sessionService.ratePerceivedQuality(session, 6),
        throwsException,
      );
    });
  });

  group("ReminderService", () {
    test("8. With the default goal the reminder is at 22:30", () {
      expect(
        reminderService.suggestBedtime(),
        Duration(hours: 22, minutes: 30),
      );
    });

    test("setReminder without a time uses the suggested bedtime", () {
      final reminder = reminderService.setReminder();
      expect(reminder.time, Duration(hours: 22, minutes: 30));
      expect(reminder.firesOnce, true);
    });

    test("setReminder rejects day 8", () {
      expect(
        () => reminderService.setReminder(repeatDays: {8}),
        throwsException,
      );
    });

    test("The suggested time wraps past midnight", () {
      goalService.setGoal(
        targetGoal: Duration(hours: 8),
        wakeTime: Duration(hours: 8, minutes: 15),
      );
      expect(
        reminderService.suggestBedtime(),
        Duration(hours: 23, minutes: 45),
      );
    });
  });
}
