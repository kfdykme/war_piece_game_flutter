

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

extension ColorRandom on Color {

  int _randomInt() {
    return Random().nextInt(55) + 100;
  }
  Color randomColor() {
    return Color.fromARGB(_randomInt(), _randomInt(), _randomInt(), _randomInt());
  }
}