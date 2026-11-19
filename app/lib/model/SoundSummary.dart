import 'SoundEvent.dart';

class Soundsummary {
  final Duration _snoring;
  final int _cough;
  final int _talking;
  final int _noise;

  Soundsummary(this._snoring, this._cough, this._talking, this._noise);

  factory Soundsummary.fromEvents(List<Soundevent> events) {
    Duration snoring = Duration.zero;
    int cough = 0;
    int talking = 0;
    int noise = 0;
    for (final event in events) {
      switch (event.type) {
        case SoundType.snoring:
          snoring += event.duration; // snoring is measured in time
          break;
        case SoundType.cough:
          cough++; // the others are counted
          break;
        case SoundType.talking:
          talking++;
          break;
        case SoundType.noise:
          noise++;
          break;
      }
    }
    return Soundsummary(snoring, cough, talking, noise);
  }

  Duration get snoring => _snoring;
  int get cough => _cough;
  int get talking => _talking;
  int get noise => _noise;
}
