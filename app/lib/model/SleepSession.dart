import 'package:flutter/material.dart';

import 'SleepGoal.dart';
import 'SoundEvent.dart';

class Sleepsession {
  final DateTime _start;
  DateTime? _end;
  final SleepGoal _goal;
  final List<Soundevent> _events = [];
  int? _perceivedQuality;
  final bool _recordSound;

  Sleepsession(this._start, this._goal, this._recordSound, {this._end});

  Duration get duration => endTimeHelper(_end?.difference(_start));

  DateTime get startTime => _start;
  DateTime get endTime => endTimeHelper(_end);
  DateTime get plannedWakeTime {
      final midnight = DateTime(_start.year, _start.month, _start.day);
      final wake = midnight.

  };
  List<Soundevent> get events => List.unmodifiable(_events);

  bool isRecording() {
    return _end == null ? true : false;
  }

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

  int? rateQuality(int q) {
    if (q < 1 || q > 5) {
      throw Exception("The rating quality and must be between 1-5");
    }
    _perceivedQuality = q;
  }

  Duration bedtimeGap() {
    return _start.difference(plannedBedTime);
  }

  Duration waketimeGap() {
    return endTimeHelper(_end?.difference(plannedWakeTime));
  }

  int rating() {
    return ((duration.inMinutes / _goal.targetGoal.inMinutes) * 100)
        .round()
        .clamp(0, 100);
  }

  Duration nightDebt() {
    return _goal.targetGoal.inMinutes > duration.inMinutes
      ? Duration.zero
      : _goal.targetGoal - duration;
  }

  dynamic endTimeHelper(dynamic returnVal) {
    if (_end == null) {
      throw Exception(
        "Cannot get the end time since the recording is still on ",
      );
    } else {
      return returnVal;
    }
  }
}

///
