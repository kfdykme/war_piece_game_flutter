import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/event/base_game_event.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/piece/archer_piece.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';
import 'package:warx_flutter/maingame/piece/gloden_piece.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/maingame/player/player_info_logic.ai.mixin.dart';
import 'package:warx_flutter/util/completer.safe.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

mixin PlayerInfoLogic {
  List<LayoutNode> importantNodes = [];
  Function? nextSkipCallback;

  int playerId = 0;

  void SetPlayerId(int id) {
    playerId = id;
  }

  void OnPlayerTurn() {}

  List<BaseGameEvent> enableEvent = [];

  void enableTurnStartEvent(GameController gameController) {
    enableEvent.clear();
    enableEvent.add(OnClickPieceEvent());
  }

  bool enable(BaseGameEvent event) {
    return enableEvent
        .where((element) =>
            element.runtimeType == event.runtimeType)
        .isNotEmpty;
  }

  Future<bool> onClickPiece(BasicPiece piece,
      GameController gameController) async {
    logD('EventLoop onClickPiece $piece');

    cancelOtherAllClickableEvent(gameController);
    notifyUI();
    if (piece is GlodenPiece) {
      logD("onClickGlodenPiece $piece");
      return false;
    } else {
      //
      Completer<bool> clickComsumePieceCompleter =
          Completer();
      final enablePlaceNodes =
          piece.GetNodesEnablePlaceNewPiece(gameController);
      logD(
          "EventLoop enablePlaceNodes ${enablePlaceNodes.length}");

      List<BaseGameEvent> clickPieceNextEvents = [];
      enablePlaceNodes.forEach((element) {
        // NOTE: 1.
        if ((element.piece == null && piece.hp == 0) ||
            element.piece == piece) {
          final e = ArragePieceEvent();
          e.completer = clickComsumePieceCompleter;
          e.nodeId = element.id;
          e.pieceId = piece.index;
          e.playerId = playerId;
          clickPieceNextEvents.add(e);
          element.nextClickCallback = () {
            gameController.OnEvent(e);
            cancelOtherAllClickableEvent(gameController);
            notifyUI();
          };
        }
      });

      // NOTE: 招募
      selectAbleItem.forEach((selectAble) {
        if (selectAble.currentAllowCount +
                selectAble.currentHandCount +
                selectAble.disableCount <
            selectAble.maxAllowCount) {
          selectAble.nextClickCallback = () {
            // final e = RecruitPieceEvent();
            // e.completer = clickComsumePieceCompleter;
            // e.pieceId = selectAble.index;
            // e.playerId = playerId;
            // clickPieceNextEvents.add(e);
            // selectAble.nextClickCallback =
            //     () {

            //   gameController.OnEvent(e);
            //   cancelOtherAllClickableEvent(
            //       gameController);
            //   notifyUI();
            //   return clickComsumePieceCompleter.future;
            // };
            //   selectAble
            //       .currentAllowCount++;
            //   comsumePiece(piece);
            //   cancelOtherAllClickableEvent(
            //       gameController);
            //   notifyUI();
            //   return true;
          };
        }
      });

      // NOTE: Skip
      final skipEvent = SkipEvent();
      skipEvent.playerId = playerId;
      skipEvent.completer = clickComsumePieceCompleter;
      skipEvent.pieceId = piece.index;
      clickPieceNextEvents.add(skipEvent);
      nextSkipCallback = buildNextSkipCall(
          gameController, piece, skipEvent);

      final movedata = piece.Move(gameController);
      clickPieceNextEvents.addAll(movedata.events);
      movedata.completer.future.then((value) {
        if (value) {
          comsumePiece(piece);
          cancelOtherAllClickableEvent(gameController);
          notifyUI();
        }
        if (piece.CanAfterMove(gameController)) {
          final List<BaseGameEvent> afterEvents = [];
          afterEvents.add(skipEvent);
          final afterMoveData =
              piece.AfterMove(gameController);
          afterEvents.addAll(afterMoveData.events);
          afterMoveData.completer.future.then((value) {
            cancelOtherAllClickableEvent(gameController);
            notifyUI();
            clickComsumePieceCompleter.safeComplete(true);
          });

          skipEvent.completer = afterMoveData.completer;
          nextSkipCallback = buildNextSkipCall(
              gameController, piece, skipEvent);
              
          enableEvent.clear();
          enableEvent.addAll(afterEvents);

          OnPlayerTurn();
        } else {
          clickComsumePieceCompleter.safeComplete(value);
        }
      });

      final attackdata = piece.Attack(gameController);
      clickPieceNextEvents.addAll(attackdata.events);
      attackdata.completer.future.then((value) {
        if (value) {
          comsumePiece(piece);
          cancelOtherAllClickableEvent(gameController);
          notifyUI();
        }
        if (piece.CanAfterAttack()) {
          final pieceAttackData =
              piece.OnAfterAttack(gameController);
          final List<BaseGameEvent> afterEvents = [];
          afterEvents.addAll(pieceAttackData.events);
          pieceAttackData.completer.future.then((value) {
            cancelOtherAllClickableEvent(gameController);
            notifyUI();
            clickComsumePieceCompleter.safeComplete(true);
          });
          skipEvent.completer = pieceAttackData.completer;
          afterEvents.add(skipEvent);
          nextSkipCallback = buildNextSkipCall(
              gameController, piece, skipEvent);

          enableEvent.clear();
          enableEvent.addAll(afterEvents);

          OnPlayerTurn();
        } else {
          clickComsumePieceCompleter.safeComplete(value);
        }
      });

      piece.Control(gameController).then((value) {
        if (value) {
          comsumePiece(piece);
          cancelOtherAllClickableEvent(gameController);
          notifyUI();
        }
        clickComsumePieceCompleter.safeComplete(value);
      });

      piece.Skill(gameController).then((value) {
        if (value) {
          comsumePiece(piece);
          cancelOtherAllClickableEvent(gameController);
          notifyUI();
        }
        clickComsumePieceCompleter.safeComplete(value);
      });

      notifyUI();

      enableEvent.clear();
      enableEvent.addAll(clickPieceNextEvents);
      OnPlayerTurn();
      return clickComsumePieceCompleter.future;
    }

    return false;
  }

  Function buildNextSkipCall(GameController gameController,
      BasicPiece piece, SkipEvent skipEvent) {
    return () {
      gameController.OnEvent(skipEvent);
      cancelOtherAllClickableEvent(gameController);
      notifyUI();
      return true;
    };
  }

  void cancelOtherAllClickableEvent(
      GameController gameController) {
    importantNodes.forEach((element) {
      element.nextClickCallback = null;
    });
    selectAbleItem.forEach((element) {
      element.nextClickCallback = null;
    });
    nextSkipCallback = null;
    gameController.map.nodes.entries.forEach((element) {
      element.value.nextClickCallback = null;
    });
  }

  void comsumePiece(BasicPiece piece) {
    final hitPiece = selectAbleItem
        .where((element) => element.index == piece.index)
        .firstOrNull;

    if (hitPiece != null) {
      hitPiece.currentHandCount--;
      hitPiece.disableCount++;
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

  BasicPiece? GetPieceByIndex(int index) {
    return selectAbleItem
        .where((element) => element.index == index)
        .firstOrNull;
  }

  bool get enableGlodenPiece => false;

  bool get hasHandItem {
    return selectAbleItem
        .where((element) => element.currentHandCount > 0)
        .isNotEmpty;
  }

  void fillPiece(int index) {
    selectAbleItem.add(BasicPiece.build(
        index: index, currentAllowCount: 2));
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
    final randomIndex =
        Random().nextInt(selectAbleItem.length);
    if (selectAbleItem[randomIndex].currentAllowCount > 0) {
      selectAbleItem[randomIndex].currentAllowCount--;
      selectAbleItem[randomIndex].currentHandCount++;
      return selectAbleItem[randomIndex];
    }

    if (selectAbleItem
        .where((element) => element.currentAllowCount > 0)
        .isEmpty) {
      selectAbleItem.forEach((element) {
        element.currentAllowCount =
            element.disableCount - element.gameOutCount;
      });
    }
    return _getSingleRandomePiece();
  }

  List<BasicPiece> getNextRandomPieces({int count = 3}) {
    List<BasicPiece> result = [];
    if (hasHandItem) {
      return result;
    }
    for (int x = 0; x < count; x++) {
      result.add(_getSingleRandomePiece());
    }
    return result;
  }
}
