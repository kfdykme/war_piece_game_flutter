import 'dart:async';

import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/event/piece_event.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';
import 'package:warx_flutter/util/completer.safe.extension.dart';

class HeavyCavalryPiece extends BasicPiece {

  HeavyCavalryPiece({required super.index, super.currentPackageCount, super.maxAllowCount, super.name});

  @override
  // TODO: implement name
  String get name => 'Heavy Cavalry';

  @override
  bool CanAfterMove(GameController gameController) {
    return true;
  }

  @override
  PieceEventBuildData AfterMove(GameController gameController) { 
    PieceEventBuildData data = PieceEventBuildData();
    final p = GetPlayer(gameController);
    final targetNodes = GetSroundedNodes(game: gameController, func: (LayoutNode node) {
       return node.piece != null && !p.selectAbleItem.contains(node.piece);
    });
    if(targetNodes.isNotEmpty) {
      Completer<bool> completer = Completer();
      targetNodes.forEach((element) {
        final piece = element.piece;

        if (piece != null) {
          PieceAttackEvent attackEvent = PieceAttackEvent();
          attackEvent.playerId = GetPlayer(gameController).id;
          attackEvent.pieceId = index;
          attackEvent.enemy = piece;
          attackEvent.enemyNode = element;
          attackEvent.attacker = this;
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
    return super.AfterMove(gameController);
  }
}