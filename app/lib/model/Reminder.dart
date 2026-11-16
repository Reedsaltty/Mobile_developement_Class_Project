class Reminder {
  final Duration _time;
  final Set<int> _repeatDays;
  bool _enabled = true;

  Reminder(this._time, this._repeatDays, this._enabled);

  Duration get time => _time;
  bool get enabled => _enabled;
  Set<int> get repeatDays => Set.unmodifiable(_repeatDays);
  bool get firesOnce => _repeatDays.isEmpty;
  void disable() {
    _enabled = false;
  }

  void enable() {
    _enabled = true;
  }
}

///
