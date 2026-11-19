import '../model/SleepReport.dart';
import '../model/SleepSession.dart';
import '../model/SoundEvent.dart';
import '../model/SoundSummary.dart';
import 'sleep_goal_service.dart';

class SleepSessionService {
  final SleepGoalService _goals;
  Sleepsession? _current; // null = nothing running
  final List<Sleepsession> _history = []; // saved nights

  SleepSessionService(this._goals);

  Sleepsession? get currentSession => _current;
  List<Sleepsession> get history => List.unmodifiable(_history);

  // Rule: only one session at a time
  Sleepsession startSession(DateTime at, {bool recordSound = false}) {
    if (_current != null) {
      throw Exception('A session is already running');
    }
    _current = Sleepsession(at, _goals.currentGoal, recordSound);
    return _current!;
  }

  // Multi-entity operation: links a Soundevent to a Sleepsession
  void recordSoundEvent(Soundevent event) {
    final session = _current;
    if (session == null) {
      throw Exception('No session is running');
    }
    session.addEvents(event); // the model checks recordSound
  }

  // Rule: under 30 minutes is discarded, not saved
  Sleepreport? stopSession(DateTime at) {
    final session = _current;
    if (session == null) {
      throw Exception('No session is running');
    }
    session.finish(at);
    _current = null; // always end it, even if discarded

    if (session.duration < const Duration(minutes: 30)) {
      return null;
    }
    _history.add(session);
    return buildReport(session);
  }

  int calculateRating(Sleepsession session) => session.rating();

  void ratePerceivedQuality(Sleepsession session, int quality) {
    session.rateQuality(quality); // the 1-5 check is in the model
  }

  Sleepreport buildReport(Sleepsession session) {
    final summary = session.recordSound
        ? Soundsummary.fromEvents(session.events)
        : null;
    return Sleepreport(
      session.duration,
      session.rating(),
      session.bedtimeGap(),
      session.waketimeGap(),
      session.nightDebt(),
      session.perceivedQuality,
      summary,
      _tip(session, summary),
    );
  }

  // Returns the first rule that matches, or null
  String? _tip(Sleepsession session, Soundsummary? summary) {
    // 1. Late by more than 30 minutes on the last 3 saved nights
    if (_history.length >= 3) {
      final lastThree = _history.sublist(_history.length - 3);
      final allLate = lastThree.every(
        (s) => s.bedtimeGap() > const Duration(minutes: 30),
      );
      if (allLate) {
        return 'You went to bed over 30 minutes late 3 nights in a row. Start winding down earlier.';
      }
    }

    // 2. More than 5 hours of debt in the last 7 days
    final weekAgo = session.startTime.subtract(const Duration(days: 7));
    Duration weeklyDebt = Duration.zero;
    for (final s in _history) {
      if (s.startTime.isAfter(weekAgo)) {
        weeklyDebt += s.nightDebt();
      }
    }
    if (weeklyDebt > const Duration(hours: 5)) {
      return 'You are over 5 hours short on sleep this week. Try an earlier night.';
    }

    // 3. More than 30 minutes of snoring tonight
    if (summary != null && summary.snoring > const Duration(minutes: 30)) {
      return 'You snored for over 30 minutes. Try sleeping on your side.';
    }

    return null;
  }
}
