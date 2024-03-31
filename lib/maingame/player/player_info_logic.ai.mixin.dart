
import 'dart:math';

import 'package:warx_flutter/maingame/event/base_game_event.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/maingame/player/player_info_logic.ext.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

class PlayerInfoAi extends PlayerInfo {

  late GameController gameController;
  PlayerInfoAi(super.id);


  @override
  void enableTurnStartEvent(GameController gameController) {
    // TODO: implement enableTurnStartEvent
    super.enableTurnStartEvent(gameController);
    this.gameController = gameController;
  }

  BaseGameEvent GetRandomeEvent() {
    return enableEvent[Random().nextInt(enableEvent.length)];
  }

    @override
  Future<void> OnPlayerTurn() async { 
    await Future.delayed(const Duration(milliseconds: 1000));
    if (enableEvent.isEmpty) {
      logE("OnEvent OnPlayerTurn empty");
      return;
    }
   final randomAiEvent = GetRandomeEvent();
    logD("OnEvent Ai ${randomAiEvent}");

   if (randomAiEvent is OnClickPieceEvent) {
          final event = OnClickPieceEvent();
          final pieces = selectAbleItem.where((element) => element.currentHandCount > 0).toList();
          if (pieces.isEmpty) {
            getNextRandomPieces();
            cancelOtherAllClickableEvent(
                gameController);
            notifyUI();
            await OnPlayerTurn();
            return;
          }
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
}