import 'dart:async';

import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';
import 'package:warx_flutter/util/completer.safe.extension.dart';

class MarksmenPiece extends BasicPiece {

  MarksmenPiece ({required super.index, super.currentAllowCount, super.maxAllowCount, super.name});
  
  @override
  // TODO: implement name
  String get name => 'Marksmen';


  @override
  Future<bool> Skill(GameController gameController) {
    
    final node = GetCurrentLayoutNode(gameController);
    if (node != null) {
    final p = GetPlayer(gameController);
    Completer<bool> completer = Completer();
      node.GetStraightNodes(game: gameController, deep: 2, func: (LayoutNode sNode) {
           return sNode.piece != null && !p.selectAbleItem.contains(sNode.piece);
      }, originNodeStopFunc: (LayoutNode oroginNode) {
        return oroginNode.piece != null;
      }).forEach((element) {
       element.nextClickCallback = () {
          final piece = element.piece;
          if (piece != null) {

            piece.hp -= hp;
            piece.gameOutCount += hp;
            if (piece.hp <= 0) {
              piece.hp = 0;
              element.piece = null;
            }
          } 
          gameController.onRefresh?.call();
          completer.safeComplete(true); 
      };
      });
      
    }

    return super.Skill(gameController);
  }
}