
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:warx_flutter/maingame/event/base_game_event.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/maingame/player/player_info_logic.ext.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

class PlayerInfoAi extends PlayerInfo {

  late GameController gameController;
  PlayerInfoAi(super.id);

  static int sCount = 0;

  @override
  void enableTurnStartEvent(GameController gameController) {
    // TODO: implement enableTurnStartEvent
    super.enableTurnStartEvent(gameController);
    this.gameController = gameController;
  }

  BaseGameEvent GetNextRandomeGameEvent() {
    return enableEvent[Random().nextInt(enableEvent.length)];
  }

    @override
  Future<void> OnPlayerTurn() async { 
    sCount++;
    if (kDebugMode) {
      if (sCount> 100) {
        return;
      }
    }
    // logD("EventLoop OnPlayerTurn wait $this");
    await Future.delayed(const Duration(milliseconds: 1000));
    logD("EventLoop OnPlayerTurn start $this");
    if (enableEvent.isEmpty) {
      logE("EventLoop empty");
      return;
    }
    logD("EventLoop enableEvent $enableEvent");
   final randomAiEvent = GetNextRandomeGameEvent() ;

   if (randomAiEvent is OnClickPieceEvent) {
          final event = OnClickPieceEvent();
          final pieces = selectAbleItem.where((element) => element.currentHandCount > 0).toList();
          event.pieceId = pieces[Random().nextInt(pieces.length)].index;
          event.playerId = id;
          gameController.OnEvent(event);
   } else {
    gameController.OnEvent(randomAiEvent);
    cancelOtherAllClickableEvent(
        gameController);
    notifyUI();
   }
  }

  @override
  String toString() {
    // TODO: implement toString
    return "PlayerAI ${playerId}";
  }
}