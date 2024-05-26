import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';

class SwordsmanPiece extends BasicPiece {

  SwordsmanPiece ({required super.index, super.currentPackageCount, super.maxAllowCount, super.name});
  @override
  // TODO: implement name
  String get name => 'Swordsman';

  @override
  PieceEventBuildData OnAfterAttack(GameController gameController) { 
    return BuildMoveAction(gameController);
  }

  @override
  bool CanAfterAttack() {
    // TODO: implement CanAfterAttack
    return true;
  }
}