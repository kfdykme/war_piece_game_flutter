
import 'dart:async';

import 'package:warx_flutter/util/log.object.extension.dart';

class EventCompleter {

  static Map<int,Completer> completers = {};
  static int sCompleterCount = 0;
  static Completer<T> GetCompleterById<T>(int completerId) {
    completers.logD("EventCompleter GetCompleterById $completerId");
    return completers[completerId]! as Completer<T>;
  }

  static Completer<T> GenerateCompleter<T>() {
    completers.logD("EventCompleter GenerateCompleter $sCompleterCount");
    return completers[sCompleterCount++] = Completer<T>();
  }

  static int GetCompleterId(Completer completer) { 
    return completers.entries.where((element) => element.value == completer).first.key;
  }
}