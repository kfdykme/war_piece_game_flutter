

import 'package:warx_flutter/util/log.object.extension.dart';

mixin NextTurnMixin {
  Function? onNextTurnCallback;
  setNextTurnCallback(Function? callback) {
    onNextTurnCallback = callback;
  }

  void notifyNextTurn() {
    logD("nextTurn");
    onNextTurnCallback?.call();
  }
}