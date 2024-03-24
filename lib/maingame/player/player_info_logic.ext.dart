
import 'dart:async';
import 'dart:math';

import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';
import 'package:warx_flutter/maingame/piece/gloden_piece.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/util/completer.safe.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

mixin PlayerInfoLogic {

  List<LayoutNode> importantNodes = [];

  Future<bool> onClickPiece(BasicPiece piece) async {
    logD('onClickPiece $piece');
    if (piece is GlodenPiece) {
       logD("onClickGlodenPiece $piece");
       return false;
    } else {
      //
      Completer<bool> clickComsumePieceCompleter = Completer();
      importantNodes.forEach((element) {
        element.nextClickCallback = () {
          var result = false;
          if (element.piece != null) {
            logD("already has piece here");
            clickComsumePieceCompleter.safeComplete(false);
          } else {
            logD("add to here");
            element.piece = piece;
            clickComsumePieceCompleter.safeComplete(true);
            comsumePiece(piece);
            result = true;
          }
          importantNodes.forEach((element) {element.nextClickCallback = null;});
          notifyUI();
          return result;
        };
      });
      notifyUI();
      return clickComsumePieceCompleter.future;
    }

    return false;
  }

  void comsumePiece(BasicPiece piece) {
    final hitPiece = selectAbleItem.where((element) => element.index == piece.index).firstOrNull;

    if (hitPiece != null) {
      hitPiece.currentHandCount--;
    }
  }

  Function? ui;

  void bindNotifyUI(Function function) {
    ui = function;
  }

  void notifyUI() {
    ui?.call();
  }
  
  List<BasicPiece> selectAbleItem = [];
  

  bool get enableGlodenPiece => false;

  bool get hasHandItem {
    return selectAbleItem.where((element) => element.currentHandCount > 0).isNotEmpty;
  }

  void fillPiece(int index) {
    selectAbleItem.add(BasicPiece(index: index, currentAllowCount: 2));
  }

  void fillPieces(List<int> indexs) {
    indexs.forEach((element) {
      fillPiece(element);
    });

    if (enableGlodenPiece) {
      selectAbleItem.add(GlodenPiece());
    }
  }


  BasicPiece _getSingleRandomePiece() {
    final randomIndex = Random().nextInt(selectAbleItem.length);
    if (selectAbleItem[randomIndex].currentAllowCount > 0) {
      selectAbleItem[randomIndex].currentAllowCount--;
      selectAbleItem[randomIndex].currentHandCount++;
      return selectAbleItem[randomIndex];
    }
    return _getSingleRandomePiece();
  }

  List<BasicPiece> getNextRandomPieces({
    int count = 3
  }) {
    List<BasicPiece> result = [];
    if (hasHandItem) {
      return result;
    }
    for(int x = 0; x < count; x++) {
      result.add(_getSingleRandomePiece());
    }
    return result;
  }

}