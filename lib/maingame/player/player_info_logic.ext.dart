import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/event/base_game_event.dart';
import 'package:warx_flutter/maingame/event/event_completer.dart';
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
  Color? playerColor;

  void SetPlayerId(int id) {
    playerId = id;
  }

  void OnPlayerTurn() {
    logD("OnPlayerTurn $this");
    getNextRandomPieces();
  }

  void OnEndPlayerTurn() {}

  late GameController gGameController;

  List<BaseGameEvent> enableEvent = [];

  static Function buildOnMoveEvent(
      PlayerInfoLogic player,
      bool value,
      BasicPiece piece,
      GameController gameController) {
    final clickComsumePieceCompleter = Completer<bool>();
    final skipEvent = SkipEvent();
    skipEvent.playerId = player.playerId;
    skipEvent.completer = clickComsumePieceCompleter;
    skipEvent.pieceId = piece.index;
    return () {
      player.logD("movedata future $value");
      if (value) {
        player.comsumePiece(piece);
        player.cancelOtherAllClickableEvent(gameController);
        player.notifyUI();
      }
      if (piece.CanAfterMove(gameController)) {
        final List<BaseGameEvent> afterEvents = [];
        skipEvent.pieceId = -1;
        afterEvents.add(skipEvent);
        final afterMoveData =
            piece.AfterMove(gameController);
        afterEvents.addAll(afterMoveData.events);
        afterMoveData.completer.future.then((value) {
          player.logD("EventLoop AfterMove ");
          player
              .cancelOtherAllClickableEvent(gameController);
          player.notifyUI();
          clickComsumePieceCompleter.safeComplete(true);
        });

        if (afterMoveData.events.isNotEmpty) {
          skipEvent.completer = afterMoveData.completer;
          player.nextSkipCallback =
              player.buildNextSkipCall(
                  gameController, piece, skipEvent);

          player.enableEvent.clear();
          player.enableEvent.addAll(afterEvents);

          player.OnPlayerTurn();
        } else {
          clickComsumePieceCompleter.safeComplete(true);

          player.comsumePiece(piece);
          player
              .cancelOtherAllClickableEvent(gameController);
          player.notifyUI();
        }
      } else {
        clickComsumePieceCompleter.safeComplete(value);
      }
    };
  }

  static Function buildOnAttackEvent(
      PlayerInfoLogic player,
      bool value,
      BasicPiece piece,
      GameController gameController) {
        
  }

  void enableTurnStartEvent(GameController gameController) {
    enableEvent.clear();
    final e = OnClickPieceEvent();
    enableEvent.add(e);
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
    }
    Completer<bool> clickComsumePieceCompleter =
        Completer();
    final enablePlaceNodes =
        piece.GetNodesEnablePlaceNewPiece(gameController);
    logD("enablePlaceNodes ${enablePlaceNodes.length}");

    List<BaseGameEvent> clickPieceNextEvents = [];
    enablePlaceNodes.forEach((element) {
      // NOTE: 1.
      if (((element.piece == null && piece.hp == 0) ||
          element.piece == piece)) {
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
      if (selectAble.enableEmpolyCount > 0) {
        final e = RecruitPieceEvent();
        e.completer = clickComsumePieceCompleter;
        e.pieceId = piece.index;
        e.playerId = playerId;
        e.targetPieceId = selectAble.index;
        clickPieceNextEvents.add(e);
        selectAble.nextClickCallback = () {
          gameController.OnEvent(e);
          cancelOtherAllClickableEvent(gameController);
          notifyUI();
          return clickComsumePieceCompleter.future;
        };
      }
    });

    // NOTE: Skip
    final skipEvent = SkipEvent();
    skipEvent.playerId = playerId;
    skipEvent.completer = clickComsumePieceCompleter;
    skipEvent.pieceId = piece.index;
    clickPieceNextEvents.add(skipEvent);
    nextSkipCallback =
        buildNextSkipCall(gameController, piece, skipEvent);

    final movedata = piece.BuildMoveAction(gameController);
    clickPieceNextEvents.addAll(movedata.events);
    movedata.completer.future.then((value) {
      buildOnMoveEvent(
          this, value, piece, gameController)();
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
        skipEvent.pieceId = -1;
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

    final controlData = piece.Control(gameController);
    clickPieceNextEvents.addAll(controlData.events);
    controlData.completer.future.then((value) {
      if (value) {
        comsumePiece(piece);
        cancelOtherAllClickableEvent(gameController);
        notifyUI();
      }
      clickComsumePieceCompleter.safeComplete(value);
    });

    final skillData = piece.Control(gameController);
    clickPieceNextEvents.addAll(skillData.events);
    skillData.completer.future.then((value) {
      if (value) {
        comsumePiece(piece);
        cancelOtherAllClickableEvent(gameController);
        notifyUI();
      }
      clickComsumePieceCompleter.safeComplete(value);
    });

    notifyUI();

    enableEvent.clear();
    if (clickPieceNextEvents.length <= 1) {
      logE("EventLoop GenerateEvents Error");
    }
    enableEvent.addAll(clickPieceNextEvents);
    OnPlayerTurn();
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

  void comsumePiece(BasicPiece piece,
      {bool disableCount = true}) {
    final hitPiece = selectAbleItem
        .where((element) => element.index == piece.index)
        .firstOrNull;

    if (hitPiece != null) {
      assert(hitPiece.currentHandCount > 0);
      hitPiece.currentHandCount--;
      if (disableCount) {
        hitPiece.disableCount++;

        if (!hasHandItem) {
          getNextRandomPieces();
          notifyUI();
        }
      }
      gGameController.nextPlayer();
    }

    logD("comsumePiece $piece");
  }

  void SetColor(Color color) {
    playerColor = color;
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
    final piece = BasicPiece.build(
        index: index, currentPackageCount: 2);
    piece.enableEmpolyCount =
        piece.maxAllowCount - piece.currentPackageCount;
    piece.color = playerColor;
    selectAbleItem.add(piece);
  }

  void fillPieces(List<int> indexs) {
    indexs.forEach((element) {
      fillPiece(element);
    });

    if (enableGlodenPiece) {
      selectAbleItem.add(GlodenPiece());
    }
  }

  BasicPiece? _getSingleRandomePiece() {
    var allowItems = selectAbleItem
        .where((element) => element.currentPackageCount > 0)
        .toList();
    if (allowItems.isNotEmpty) {
      final randomIndex =
          Random(playerId).nextInt(allowItems.length);
      if (allowItems[randomIndex].currentPackageCount > 0) {
        allowItems[randomIndex].currentPackageCount--;
        allowItems[randomIndex].currentHandCount++;
        return allowItems[randomIndex];
      }
    }

    if (selectAbleItem
        .where((element) => element.currentPackageCount > 0)
        .isEmpty) {
      selectAbleItem
          .where((element) =>
              element.currentPackageCount == 0 &&
              element.currentHandCount == 0)
          .forEach((element) {
        element.currentPackageCount = element.disableCount;
        element.disableCount = 0;
      });
    }
    allowItems = selectAbleItem
        .where((element) => element.currentPackageCount > 0)
        .toList();
    if (allowItems.isNotEmpty) {
      return _getSingleRandomePiece();
    } else {
      return null;
    }
  }

  List<BasicPiece> getNextRandomPieces({int count = 3}) {
    List<BasicPiece> result = [];
    if (hasHandItem) {
      return result;
    }
    for (int x = 0; x < count; x++) {
      final next = _getSingleRandomePiece();
      if (next == null) {
        break;
      }
      result.add(next);
    }
    logD("getNextRandomPieces $result");
    return result;
  }
}
