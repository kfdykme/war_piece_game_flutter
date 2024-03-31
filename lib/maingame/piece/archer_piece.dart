
import 'dart:async';

import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';
import 'package:warx_flutter/util/completer.safe.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

class ArcherPiece extends BasicPiece {
  ArcherPiece({required super.index, super.currentAllowCount, super.maxAllowCount, super.name});

  @override
  // TODO: implement name
  String get name => 'Archer';


  @override
  PieceEventBuildData Attack(GameController game) {
    return PieceEventBuildData();
  }
  @override
  Future<bool> Skill(GameController gameController) {

    Completer<bool> completer = Completer();
    final p = GetPlayer(gameController);
    final targetNodes = GetSroundedNodes(game: gameController, func: (LayoutNode node) {
      return node.piece != null && !p.selectAbleItem.contains(node.piece);
    }, deep: 2);

    logD("targetNodes ${targetNodes}");
    targetNodes.forEach((element) {
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
