import 'package:flutter/foundation.dart';

class MusicTypeNotifier extends ValueNotifier<MusicType> {
  MusicTypeNotifier() : super(_initialValue);
  static const _initialValue = MusicType.none;
}

enum MusicType { none, live, playlist }
