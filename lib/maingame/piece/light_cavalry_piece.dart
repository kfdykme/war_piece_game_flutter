import 'package:warx_flutter/maingame/piece/basic_piece.dart';

class LightCavalryPiece extends BasicPiece {
   LightCavalryPiece ({required super.index, super.currentAllowCount, super.maxAllowCount, super.name});
  @override
  // TODO: implement name
  String get name => 'LightCavalry';

  @override
  MoveConfig GetMoveConfig() {
    // TODO: implement GetMoveConfig
    return MoveConfig(2);
  }
}