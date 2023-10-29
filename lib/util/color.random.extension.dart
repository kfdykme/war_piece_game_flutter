

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

extension ColorRandom on Color {

  int _randomInt() {
    return Random().nextInt(120) + 70;
  }
  Color randomColor() {
    return Color.fromARGB(_randomInt(), _randomInt(), _randomInt(), _randomInt());
  }
}