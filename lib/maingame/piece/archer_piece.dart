
import 'dart:async';

import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';
import 'package:warx_flutter/util/completer.safe.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

class ArcherPiece extends BasicPiece {
  ArcherPiece({required super.index, super.currentAllowCount});

  @override
  // TODO: implement name
  String get name => 'Archer';

  @override
  Future<bool> Attack(GameController game) async { 
    return Completer<bool>().future;
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
    return completer.future;
  }
}