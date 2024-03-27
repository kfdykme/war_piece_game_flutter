
import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';

class SperamenPiece extends BasicPiece {
  
  SperamenPiece ({required super.index, super.currentAllowCount, super.maxAllowCount, super.name});

  @override
  // TODO: implement name
  String get name => 'Speramen';


  @override
  void OnAttack(BasicPiece attackerPiece, GameController game) {
    super.OnAttack(attackerPiece, game);
    final nearAttackerPiece = GetSroundedNodes(game: game, func: (LayoutNode node) {
      return node.piece == attackerPiece;
    }).firstOrNull?.piece;
    if (nearAttackerPiece != null) { 
      if (nearAttackerPiece.enableEmpolyCount == 0) {
        if (nearAttackerPiece.currentAllowCount > 0) {
          nearAttackerPiece.currentAllowCount--;
        } else if (nearAttackerPiece.disableCount > 0) {
          nearAttackerPiece.disableCount--;
        } else if (nearAttackerPiece.currentHandCount > 0) {
          nearAttackerPiece.currentHandCount--;
        } else {
          nearAttackerPiece.hp--;
          if (nearAttackerPiece.hp == 0) {
            final node = nearAttackerPiece.GetCurrentLayoutNode(game);
            node?.piece = null;
          }
        }
      }
     nearAttackerPiece.gameOutCount++;
    }
  }
}