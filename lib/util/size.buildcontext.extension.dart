

import 'package:flutter/material.dart';

extension BuildContextSize on BuildContext 
{
  Size mSize() {
    return MediaQuery.of(this).size;
  }
}