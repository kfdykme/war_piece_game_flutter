import 'package:warx_flutter/maingame/piece/basic_piece.dart';

class LightCavalryPiece extends BasicPiece {
   LightCavalryPiece ({required super.index, super.currentPackageCount, super.maxAllowCount, super.name});
  @override
  // TODO: implement name
  String get name => 'LightCavalry';

  @override
  MoveConfig GetMoveConfig() {
    return MoveConfig(2);
  }
}