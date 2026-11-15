class SleepGoal {
  final Duration _TargetGoal;
  final Duration _wakeTime;

  SleepGoal({required this._TargetGoal, required this._wakeTime});

  bool isValid() {
    return (_TargetGoal.inMinutes >= 240 &&
        _TargetGoal.inMinutes <= 720 &&
        _TargetGoal.inMinutes % 15 == 0);
  }

  Duration get bedtime => (_wakeTime - _TargetGoal);
  Duration get waketime => _wakeTime;
  Duration get targetGoal => _TargetGoal;
}

///
