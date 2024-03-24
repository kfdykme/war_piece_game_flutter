
import 'dart:convert';

class BasicPiece {
  final int index;
  final int maxAllowCount;
  int currentAllowCount;
  int currentHandCount = 0;
  // 弃牌堆中的数量
  int disableCount = 0;

  // 本场游戏不能使用的数量
  int gameOutCount = 0;
  int hp = 0;
  final String name;

  Function? nextClickCallback;
  BasicPiece({
    required this.index ,
    this.maxAllowCount = 5,
    this.currentAllowCount = 0,
    this.name = ''
  });

  int get enableEmpolyCount => maxAllowCount - gameOutCount - currentAllowCount - currentHandCount - disableCount;

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
  @override
  // TODO: implement hashCode
  int get hashCode => index;
}