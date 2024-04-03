
import 'dart:async';

import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/event/piece_event.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';
import 'package:warx_flutter/util/completer.safe.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

class ArcherPiece extends BasicPiece {
  ArcherPiece({required super.index, super.currentPackageCount, super.maxAllowCount, super.name});

  @override
  // TODO: implement name
  String get name => 'Archer';


  @override
  PieceEventBuildData Attack(GameController game) {
    return PieceEventBuildData();
  }
  @override
  PieceEventBuildData Skill(GameController gameController) {
    PieceEventBuildData data = PieceEventBuildData();
    Completer<bool> completer = Completer();
    data.completer = completer;
    final p = GetPlayer(gameController);
    final targetNodes = GetSroundedNodes(game: gameController, func: (LayoutNode node) {
      return node.piece != null && !p.selectAbleItem.contains(node.piece);
    }, deep: 2);

    logD("targetNodes ${targetNodes}");
    targetNodes.forEach((element) {
      targetNodes.forEach((element) {
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
    });
    return data;
  }

  @override
  Map<String,dynamic> getConfig() {
    return {
      'attack': {
        'enable': false 
      },
      'move': {},
      'skill': {
        'target': {
          'deep': 2,
          'condition': [
            'not_empty_piece',
            'not_friend_piece'
          ],
        },
        'mode': 'hit'
      }
    };
  }
}
