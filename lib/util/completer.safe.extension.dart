
import 'dart:async';

import 'package:warx_flutter/util/log.object.extension.dart';

extension SafeCompleteExtension<T> on Completer<T> {
  void safeComplete(T value) {
    if (!isCompleted) {
      complete(value);
    } else {
      logD("already complete");
    }
  }
}