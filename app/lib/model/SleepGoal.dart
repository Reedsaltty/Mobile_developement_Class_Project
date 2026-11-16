class SleepGoal {
  final Duration _targetGoal;
  final Duration _wakeTime;

  SleepGoal({required this._targetGoal, required this._wakeTime});

  bool isValid() {
    return (_targetGoal.inMinutes >= 240 &&
        _targetGoal.inMinutes <= 720 &&
        _targetGoal.inMinutes % 15 == 0);
  }

  Duration get bedtime {
     final minutes = _wakeTime.inMinutes - _targetGoal.inMinutes;
        final wrapped = minutes % 1440;
        return Duration(minutes: wrapped);
  }
  Duration get waketime => _wakeTime;
  Duration get targetGoal => _targetGoal;
}

///
