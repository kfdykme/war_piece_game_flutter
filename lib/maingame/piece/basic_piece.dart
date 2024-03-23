
import 'dart:convert';

class BasicPiece {
  final int index;
  final int maxAllowCount;
  int currentAllowCount;
  int currentHandCount = 0;
  final String name;
  BasicPiece({
    required this.index ,
    this.maxAllowCount = 5,
    this.currentAllowCount = 0,
    this.name = ''
  });

  @override
  String toString() {
    return jsonEncode(Map.from({
      'name':name,
      'index':index,
      'maxAllowCount':maxAllowCount,
      'currentAllowCount':currentAllowCount,
      'currentHandCount':currentHandCount,
    }));
  }
}