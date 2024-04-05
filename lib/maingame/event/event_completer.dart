
import 'dart:async';

class EventCompleter {

  static Map<int,Completer> completers = {};
  static int sCompleterCount = 0;
  static Completer<T> GetCompleterById<T>(int completerId) {
    return completers[completerId]! as Completer<T>;
  }

  static Completer<T> GenerateCompleter<T>() {
    return completers[sCompleterCount++] = Completer<T>();
  }

  static int GetCompleterId(Completer completer) {
    return completers.entries.where((element) => element.value == completer).first.key;
  }
}