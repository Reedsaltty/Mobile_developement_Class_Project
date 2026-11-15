import 'package:flutter/foundation.dart';

enum SoundType { Snoring, Talking, Cought, Noise }

class Soundevent {
  final SoundType _type;
  final Duration _duration;
  final DateTime _timeStamp;
  final double _confident;

  Soundevent(this._type, this._duration, this._timeStamp, this._confident) {
    if (_duration.isNegative) {
      throw Exception("Duration can't be negative");
    }
    if (_confident < 0 || _confident > 1) {
      throw Exception("Confident shall be in the range of 0-1");
    }
  }
}

///
