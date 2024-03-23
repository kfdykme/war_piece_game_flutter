
import 'package:flutter/widgets.dart';
import 'package:warx_flutter/util/state.extension.dart';

extension StateUpdateExtension on State {
  void updateState() {
    // setSta
    setStateIfMounted();
  }
}