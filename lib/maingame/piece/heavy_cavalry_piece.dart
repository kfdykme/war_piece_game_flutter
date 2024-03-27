import 'dart:async';

import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';
import 'package:warx_flutter/util/completer.safe.extension.dart';

class HeavyCavalryPiece extends BasicPiece {

  HeavyCavalryPiece({required super.index, super.currentAllowCount, super.maxAllowCount, super.name});

  @override
  // TODO: implement name
  String get name => 'Heavy Cavalry';

  @override
  bool CanAfterMove(GameController gameController) {
    return true;
  }

  @override
  Future<bool> AfterMove(GameController gameController) async { 
    final p = GetPlayer(gameController);
    final targetNodes = GetSroundedNodes(game: gameController, func: (LayoutNode node) {
       return node.piece != null && !p.selectAbleItem.contains(node.piece);
    });
    if(targetNodes.isNotEmpty) {
      Completer<bool> completer = Completer();
      targetNodes.forEach((element) {
        element.nextClickCallback = () {
          final piece = element.piece;
          if (piece != null) {
           DoAttack(piece, element);
          }
          gameController.onRefresh?.call();
          completer.safeComplete(true); 
        };
      });
      return completer.future;
    }
    return super.AfterMove(gameController);
  }
}