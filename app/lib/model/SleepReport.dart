import 'SoundSummary.dart';

class Sleepreport {
  final Duration _duration;
  final int _rating;
  final Duration _bedtimeGap;
  final Duration _wakeupGap;
  final Duration _nightDebt;
  final int? _perceivedQuality;
  final Soundsummary? _soundsummary;
  final String? _tip;

  Sleepreport(
    this._duration,
    this._rating,
    this._bedtimeGap,
    this._wakeupGap,
    this._nightDebt,
    this._perceivedQuality,
    this._soundsummary,
    this._tip,
  );

  Duration get duration => _duration;
  int get rating => _rating;
  Duration get bedtimeGap => _bedtimeGap;
  Duration get wakeupGap => _wakeupGap;
  Duration get nightDebt => _nightDebt;
  int? get perceivedQuality => _perceivedQuality;
  Soundsummary? get soundSummary => _soundsummary;
  String? get tip => _tip;
  bool get forgotToStop => _duration > const Duration(hours: 16);
}
