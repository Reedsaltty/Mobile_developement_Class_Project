import 'package:app/model/SleepGoal.dart';
import 'package:app/model/SleepSession.dart';
import 'package:app/model/SoundEvent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Normal test case", () {
    test("8-hour session against an 8-hour goal to recieved 100% rating", () {
      final SleepGoal goal = SleepGoal(
        targetGoal: Duration(hours: 8),
        wakeTime: Duration(hours: 7),
      );
      final Sleepsession session = Sleepsession(
        DateTime(2026, 11, 16, 23, 0),
        goal,
        true,
      );

      session.finish(DateTime(2026, 11, 17, 7, 0));
      expect(session.rating(), 100);
    });

    test("Add event to a running session", () {
      final SleepGoal goal = SleepGoal(
        targetGoal: Duration(hours: 8),
        wakeTime: Duration(hours: 7),
      );
      final Sleepsession session = Sleepsession(
        DateTime(2026, 11, 16, 23, 0),
        goal,
        true,
      );
      Soundevent event1 = Soundevent(
        SoundType.snoring,
        Duration(minutes: 1),
        DateTime(2026, 11, 17, 3, 0),
        0.67,
      );
      session.addEvents(event1);

      session.finish(DateTime(2026, 11, 17, 7, 0));
      expect(session.events.isEmpty, false);
    });

    test("Night 23:15 to 06:30, goal 8 h, wake 06:30", () {
      SleepGoal goal = SleepGoal(
        targetGoal: Duration(hours: 8),
        wakeTime: Duration(hours: 6, minutes: 30),
      );
      Sleepsession session = Sleepsession(
        DateTime(2026, 11, 16, 23, 15),
        goal,
        true,
      );
      session.finish(DateTime(2026, 11, 17, 6, 30));

      expect(session.duration, Duration(hours: 7, minutes: 15));
      expect(session.rating(), 91);
      expect(session.waketimeGap(), Duration.zero);
      expect(session.bedtimeGap(), Duration(minutes: 45));
      expect(session.nightDebt(), Duration(minutes: 45));
    });
  });

  group("Invalid test case", () {
    test("A 3-hour goal is invalid", () {
      SleepGoal goal = SleepGoal(
        targetGoal: Duration(hours: 3),
        wakeTime: Duration(hours: 6),
      );

      expect(goal.isValid(), false);
    });

    test("Perceived quality of 0 or 6 is rejected", () {
      SleepGoal goal = SleepGoal(
        targetGoal: Duration(hours: 8),
        wakeTime: Duration(hours: 7),
      );
      Sleepsession session = Sleepsession(
        DateTime(2026, 11, 16, 23, 0),
        goal,
        false,
      );

      expect(() => session.rateQuality(0), throwsException);
      expect(() => session.rateQuality(6), throwsException);
    });

    test("Adding a sound event with recording off is rejected", () {
      SleepGoal goal = SleepGoal(
        targetGoal: Duration(hours: 8),
        wakeTime: Duration(hours: 7),
      );
      Sleepsession session = Sleepsession(
        DateTime(2026, 11, 16, 23, 0),
        goal,
        false,
      );
      Soundevent event1 = Soundevent(
        SoundType.snoring,
        Duration(minutes: 1),
        DateTime(2026, 11, 17, 3, 0),
        0.67,
      );

      expect(() => session.addEvents(event1), throwsException);
    });

    test("A sound event with confidence above 1 is rejected", () {
      expect(
        () => Soundevent(
          SoundType.cough,
          Duration(seconds: 5),
          DateTime(2026, 11, 17, 3, 0),
          2,
        ),
        throwsException,
      );
    });

    test("Finishing a session before it started is rejected", () {
      SleepGoal goal = SleepGoal(
        targetGoal: Duration(hours: 8),
        wakeTime: Duration(hours: 7),
      );
      Sleepsession session = Sleepsession(
        DateTime(2026, 11, 16, 23, 0),
        goal,
        false,
      );

      expect(
        () => session.finish(DateTime(2026, 11, 16, 22, 0)),
        throwsException,
      );
    });
  });

  group("Boundary test case", () {
    test("Set goals of exactly 4 and exactly 12 hours", () {
      SleepGoal goal1 = SleepGoal(
        targetGoal: Duration(hours: 4),
        wakeTime: Duration(hours: 6),
      );
      SleepGoal goal2 = SleepGoal(
        targetGoal: Duration(hours: 12),
        wakeTime: Duration(hours: 6),
      );
      expect(goal1.isValid() && goal2.isValid(), true);
    });

    test("9-hour night against an 8-hour goal", () {
      SleepGoal goal = SleepGoal(
        targetGoal: Duration(hours: 8),
        wakeTime: Duration(hours: 7),
      );
      Sleepsession session = Sleepsession(
        DateTime(2026, 11, 16, 22, 0),
        goal,
        true,
      );

      session.finish(DateTime(2026, 11, 17, 7));
      expect(session.rating(), 100);
      expect(session.nightDebt(), Duration.zero);
    });
  });

  group("Special test case", () {
    test("Goal 6 h, wake 07:00 (bedtime after midnight)", () {
      SleepGoal goal = SleepGoal(
        targetGoal: Duration(hours: 6),
        wakeTime: Duration(hours: 7),
      );

      expect(goal.bedtime, Duration(hours: 1));
    });

    test("Reading duration before the session is finished throws", () {
      SleepGoal goal = SleepGoal(
        targetGoal: Duration(hours: 8),
        wakeTime: Duration(hours: 7),
      );
      Sleepsession session = Sleepsession(
        DateTime(2026, 11, 16, 23, 15),
        goal,
        false,
      );

      expect(() => session.duration, throwsException);
    });

    test("Finishing a session twice is rejected", () {
      SleepGoal goal = SleepGoal(
        targetGoal: Duration(hours: 8),
        wakeTime: Duration(hours: 7),
      );
      Sleepsession session = Sleepsession(
        DateTime(2026, 11, 16, 23, 0),
        goal,
        false,
      );
      session.finish(DateTime(2026, 11, 17, 7, 0));

      expect(
        () => session.finish(DateTime(2026, 11, 17, 7, 30)),
        throwsException,
      );
    });
  });
}
