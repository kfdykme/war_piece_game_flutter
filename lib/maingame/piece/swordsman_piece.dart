import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';

class SwordsmanPiece extends BasicPiece {

  SwordsmanPiece ({required super.index, super.currentAllowCount, super.maxAllowCount, super.name});
  @override
  // TODO: implement name
  String get name => 'Swordsman';

  @override
  Future<bool> OnAfterAttack(GameController gameController) { 
    return Move(gameController);
  }

  @override
  bool CanAfterAttack() {
    // TODO: implement CanAfterAttack
    return true;
  }
}