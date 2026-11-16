import 'SleepGoal.dart';
import 'SoundEvent.dart';

class Sleepsession {
  final DateTime _start;
  DateTime? _end;
  final SleepGoal _goal;
  final List<Soundevent> _events = [];
  int? _perceivedQuality;
  final bool _recordSound;

  Sleepsession(this._start, this._goal, this._recordSound);

  Duration get duration {
    _checkFinished();
    return _end!.difference(_start);
  }
  int? get perceivedQuality => _perceivedQuality ;
  bool get recordSound => _recordSound ;
  SleepGoal get goal => _goal ;
  DateTime get startTime => _start;
  DateTime get endTime {
    _checkFinished();
    return _end! ;
  }
  DateTime get plannedWakeTime {
    final nightTime = DateTime(_start.year, _start.month, _start.day);
    DateTime wake = nightTime.add(_goal.waketime);

    if (wake.isBefore(_start)) {
      wake = wake.add(const Duration(days: 1));
    }
    return wake;
  }

  DateTime get plannedBedTime => plannedWakeTime.subtract(_goal.targetGoal);
  List<Soundevent> get events => List.unmodifiable(_events);

  bool isRecording() => _end == null ;

  void finish(DateTime at) {
    if (!isRecording()) {
      throw Exception("Session is already end");
    }
    if (at.isBefore(_start)) {
      throw Exception("Finish time can not be before start time");
    }
    _end = at;
  }

  void addEvents(Soundevent e) {
    if (!_recordSound) {
      throw Exception("Event can not be added while recording is off");
    }
    _events.add(e);
  }
 
  void rateQuality(int q) {
    if (q < 1 || q > 5) {
      throw Exception("The rating quality and must be between 1-5");
    }
    _perceivedQuality = q;
  }

  Duration bedtimeGap() {
    return _start.difference(plannedBedTime);
  }

  Duration waketimeGap() {
    _checkFinished();
    return _end!.difference(plannedWakeTime);
  }

  int rating() {
    return ((duration.inMinutes / _goal.targetGoal.inMinutes) * 100)
        .round()
        .clamp(0, 100);
  }

  Duration nightDebt() {
    return _goal.targetGoal.inMinutes > duration.inMinutes
        ? _goal.targetGoal - duration
        : Duration.zero;
  }

  void _checkFinished() {
    if (_end == null) {
      throw Exception('Session is still running');
    }
  }
}

///
