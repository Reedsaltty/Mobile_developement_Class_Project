import '../model/SleepGoal.dart';

class SleepGoalService {
  SleepGoal _currentGoal = SleepGoal(
    targetGoal: Duration(hours: 8), // default 8 hours
    wakeTime: Duration(hours: 7), // default 07:00
  );

  SleepGoal get currentGoal => _currentGoal;

  SleepGoal setGoal({
    required Duration targetGoal,
    required Duration wakeTime,
  }) {
    final newGoal = SleepGoal(targetGoal: targetGoal, wakeTime: wakeTime);
    if (!newGoal.isValid()) {
      throw Exception('Goal must be 4 to 12 hours in 15-minute steps');
    }
    _currentGoal = newGoal; // only saved when valid
    return newGoal;
  }
}
