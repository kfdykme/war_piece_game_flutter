import 'dart:async';
import 'dart:ui';

import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/event/piece_event.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';
import 'package:warx_flutter/util/completer.safe.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

class LancerPiece extends BasicPiece {
  LancerPiece ({required super.index, super.currentPackageCount, super.maxAllowCount, super.name});
  @override
  // TODO: implement name
  String get name => 'Lancer';

  @override
  PieceEventBuildData Attack(GameController game) {
    return PieceEventBuildData();
  }

  @override
  PieceEventBuildData Skill(GameController gameController) { 
    PieceEventBuildData data = PieceEventBuildData();
    final node = GetCurrentLayoutNode(gameController);
    if (node != null) {
      final p = GetPlayer(gameController);
      final sroundNodes = node.GetStraightNodes(game: gameController, deep: 2, func: (LayoutNode node) {
      return node.piece != null && !p.selectAbleItem.contains(node.piece);
    });
       

      Completer<bool> completer = Completer();
      data.completer = completer;
      sroundNodes.forEach((element) {
       final piece = element.piece;

        if (piece != null) {
          PieceAttackEvent attackEvent = PieceAttackEvent();
          attackEvent.playerId = GetPlayer(gameController).id;
          attackEvent.pieceId = index;
          attackEvent.enemy = piece;
          attackEvent.enemyNode = element;
          attackEvent.attacker = this;
          attackEvent.completer = data.completer;
          data.events.add(attackEvent);
          element.nextClickCallback = () {
            gameController.OnEvent(attackEvent);
            // DoAttack(piece, element, gameController);
            // gameController.onRefresh?.call();
            // completer.safeComplete(true); 
          };
        }
      });
      return data;
    }
    return super.Skill(gameController);
  }
}