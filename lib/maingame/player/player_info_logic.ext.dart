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

  void enableTurnStartEvent(
      GameController gameController) {
    enableEvent.clear();
    enableEvent
        .add(OnClickPieceEvent());
  }

  void generateClickPieceNextEvent(
      BasicPiece piece,
      GameController gameController,
      Completer<bool> completer) {
    enableEvent.clear();
    //1. generate arrange event

    final enablePlaceNodes = piece
        .GetNodesEnablePlaceNewPiece(
            gameController);
    logD(
        "enablePlaceNodes ${enablePlaceNodes.length}");
    enablePlaceNodes.forEach((node) {
      if ((node.piece == null &&
              piece.hp == 0) ||
          node.piece == piece) {
        final arrangePieceEvent =
            ArragePieceEvent();
        arrangePieceEvent.nodeId =
            node.id;
        arrangePieceEvent.pieceId =
            piece.index;
        arrangePieceEvent.completer =
            completer;
        arrangePieceEvent.playerId =
            playerId;
      }
    });
  }

  bool enable(BaseGameEvent event) {
    return enableEvent
        .where((element) =>
            element.runtimeType ==
            event.runtimeType)
        .isNotEmpty;
  }

  Future<bool> onClickPiece(
      BasicPiece piece,
      GameController
          gameController) async {
    logD('onClickPiece $piece');

    cancelOtherAllClickableEvent(
        gameController);
    notifyUI();
    if (piece is GlodenPiece) {
      logD("onClickGlodenPiece $piece");
      return false;
    } else {
      //
      Completer<bool>
          clickComsumePieceCompleter =
          Completer();
      final enablePlaceNodes = piece
          .GetNodesEnablePlaceNewPiece(
              gameController);
      logD(
          "enablePlaceNodes ${enablePlaceNodes.length}");
      // generateClickPieceNextEvent(piece, gameController, clickComsumePieceCompleter);

      List<BaseGameEvent>
          clickPieceNextEvents = [];
      enablePlaceNodes
          .forEach((element) {
        // NOTE: 1.
        if ((element.piece == null &&
                piece.hp == 0) ||
            element.piece == piece) {
          final e = ArragePieceEvent();
          e.completer =
              clickComsumePieceCompleter;
          e.nodeId = element.id;
          e.pieceId = piece.index;
          e.playerId = playerId;
          clickPieceNextEvents.add(e);
          element.nextClickCallback =
              () {
            gameController.OnEvent(e);
            cancelOtherAllClickableEvent(
                gameController);
            notifyUI();
          };
        }
      });

      // NOTE: 招募
      selectAbleItem
          .forEach((selectAble) {
        if (selectAble
                    .currentAllowCount +
                selectAble
                    .currentHandCount +
                selectAble
                    .disableCount <
            selectAble.maxAllowCount) {

          final e = RecruitPieceEvent();  
          e.completer = clickComsumePieceCompleter;
          e.pieceId = selectAble.index;
          e.playerId = playerId;  
          clickPieceNextEvents.add(e);
          selectAble.nextClickCallback =
              () {
            
            gameController.OnEvent(e);
            cancelOtherAllClickableEvent(
                gameController);
            notifyUI();
            return clickComsumePieceCompleter.future;
          };
        }
      });

      // NOTE: Skip
      final skipEvent = SkipEvent();
      skipEvent.pieceId = piece.index;
      skipEvent.playerId = playerId;
      skipEvent.completer = clickComsumePieceCompleter;
      clickPieceNextEvents.add(skipEvent);
    clickPieceNextEvents
        .add(OnClickPieceEvent());
      nextSkipCallback =
          buildNextSkipCall(
              gameController, piece,skipEvent);

      piece.Move(gameController)
          .then((value) {
        if (value) {
          comsumePiece(piece);
          cancelOtherAllClickableEvent(
              gameController);
          notifyUI();
        }
        if (piece.CanAfterMove(
            gameController)) {
          nextSkipCallback =
              buildNextSkipCall(
                  gameController,
                  piece,skipEvent);
          piece.AfterMove(
                  gameController)
              .then((value) {
            cancelOtherAllClickableEvent(
                gameController);
            notifyUI();
            clickComsumePieceCompleter
                .safeComplete(true);
          });
        } else {
          clickComsumePieceCompleter
              .safeComplete(value);
        }
      });

      piece.Attack(gameController)
          .then((value) {
        if (value) {
          comsumePiece(piece);
          cancelOtherAllClickableEvent(
              gameController);
          notifyUI();
        }
        if (piece.CanAfterAttack()) {
          nextSkipCallback =
              buildNextSkipCall(
                  gameController,
                  piece,skipEvent);
          piece.OnAfterAttack(
                  gameController)
              .then((value) {
            cancelOtherAllClickableEvent(
                gameController);
            notifyUI();
            clickComsumePieceCompleter
                .safeComplete(true);
          });
        } else {
          clickComsumePieceCompleter
              .safeComplete(value);
        }
      });

      piece.Control(gameController)
          .then((value) {
        if (value) {
          comsumePiece(piece);
          cancelOtherAllClickableEvent(
              gameController);
          notifyUI();
        }
        clickComsumePieceCompleter
            .safeComplete(value);
      });

      piece.Skill(gameController)
          .then((value) {
        if (value) {
          comsumePiece(piece);
          cancelOtherAllClickableEvent(
              gameController);
          notifyUI();
        }
        clickComsumePieceCompleter
            .safeComplete(value);
      });

      notifyUI();

      enableEvent.clear();
      enableEvent.addAll(clickPieceNextEvents);
      OnPlayerTurn();
      return clickComsumePieceCompleter
          .future;
    }

    return false;
  }

  Function buildNextSkipCall(
      GameController gameController,
      BasicPiece piece, SkipEvent event) {
    return () {
      gameController.OnEvent(event);
      // comsumePiece(piece);
      cancelOtherAllClickableEvent(
          gameController);
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
    gameController.map.nodes.entries
        .forEach((element) {
      element.value.nextClickCallback =
          null;
    });
  }

  void comsumePiece(BasicPiece piece) {
    final hitPiece = selectAbleItem
        .where((element) =>
            element.index ==
            piece.index)
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

  BasicPiece? GetPieceByIndex(
      int index) {
    return selectAbleItem
        .where((element) =>
            element.index == index)
        .firstOrNull;
  }

  bool get enableGlodenPiece => false;

  bool get hasHandItem {
    return selectAbleItem
        .where((element) =>
            element.currentHandCount >
            0)
        .isNotEmpty;
  }

  void fillPiece(int index) {
    selectAbleItem.add(BasicPiece.build(
        index: index,
        currentAllowCount: 2));
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
    final randomIndex = Random()
        .nextInt(selectAbleItem.length);
    if (selectAbleItem[randomIndex]
            .currentAllowCount >
        0) {
      selectAbleItem[randomIndex]
          .currentAllowCount--;
      selectAbleItem[randomIndex]
          .currentHandCount++;
      return selectAbleItem[
          randomIndex];
    }

    if (selectAbleItem
        .where((element) =>
            element.currentAllowCount >
            0)
        .isEmpty) {
      selectAbleItem.forEach((element) {
        element.currentAllowCount =
            element.disableCount -
                element.gameOutCount;
      });
    }
    return _getSingleRandomePiece();
  }

  List<BasicPiece> getNextRandomPieces(
      {int count = 3}) {
    List<BasicPiece> result = [];
    if (hasHandItem) {
      return result;
    }
    for (int x = 0; x < count; x++) {
      result.add(
          _getSingleRandomePiece());
    }
    return result;
  }
}
