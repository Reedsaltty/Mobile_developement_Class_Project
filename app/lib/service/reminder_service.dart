import '../model/Reminder.dart';
import 'sleep_goal_service.dart';

class ReminderService {
  final SleepGoalService _goals;
  Reminder? _reminder;

  ReminderService(this._goals);

  Reminder? get reminder => _reminder;

  Duration suggestBedtime() {
    final minutes = _goals.currentGoal.bedtime.inMinutes - 30;
    return Duration(minutes: minutes % 1440); // 00:15 - 30 min = 23:45
  }

  Reminder setReminder({
    Duration? time,
    Set<int> repeatDays = const {},
    bool enabled = true,
  }) {
    for (final day in repeatDays) {
      if (day < 1 || day > 7) {
        throw Exception('Days must be 1 (Monday) to 7 (Sunday)');
      }
    }
    // ?? means: use time if it is not null, otherwise the suggestion
    final reminder = Reminder(time ?? suggestBedtime(), repeatDays, enabled);
    _reminder = reminder;
    return reminder;
  }
}
