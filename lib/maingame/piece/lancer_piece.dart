import 'dart:async';
import 'dart:ui';

import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';
import 'package:warx_flutter/util/completer.safe.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

class LancerPiece extends BasicPiece {
  LancerPiece ({required super.index, super.currentAllowCount, super.maxAllowCount, super.name});
  @override
  // TODO: implement name
  String get name => 'Lancer';

  @override
  PieceEventBuildData Attack(GameController game) {
    return PieceEventBuildData();
  }

  @override
  Future<bool> Skill(GameController gameController) {
    logD("try Skill");
    final node = GetCurrentLayoutNode(gameController);
    if (node != null) {
      final p = GetPlayer(gameController);
      final sroundNodes = node.GetStraightNodes(game: gameController, deep: 2, func: (LayoutNode node) {
      return node.piece != null && !p.selectAbleItem.contains(node.piece);
    });
       

      Completer<bool> completer = Completer();
      sroundNodes.forEach((element) {
        element.nextClickCallback = () {

          final piece = element.piece;
          if (piece != null) {
           DoAttack(piece, element, gameController);
          }
          gameController.onRefresh?.call();
          completer.safeComplete(true); 
        };
      });
      return completer.future;
    }
    return super.Skill(gameController);
  }
}