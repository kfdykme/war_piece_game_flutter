
import 'package:warx_flutter/maingame/piece/basic_piece.dart';

class SperamenPiece extends BasicPiece {
  
  SperamenPiece ({required super.index, super.currentAllowCount, super.maxAllowCount, super.name});

  @override
  // TODO: implement name
  String get name => 'Speramen';


  @override
  void OnAttack(BasicPiece attackerPiece) {
    super.OnAttack(attackerPiece);
    
  }
}