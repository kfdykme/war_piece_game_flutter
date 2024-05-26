

import 'package:flutter/material.dart';

extension SafeState on State {

  void setStateIfMounted() {
    if (mounted) {
      setState(() {
        
      });
    }
  }
}