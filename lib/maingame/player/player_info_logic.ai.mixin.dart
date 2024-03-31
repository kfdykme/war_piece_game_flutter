
import 'dart:math';

import 'package:warx_flutter/maingame/event/base_game_event.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/maingame/player/player_info_logic.ext.dart';

class PlayerInfoAi extends PlayerInfo {

  late GameController gameController;
  PlayerInfoAi(super.id);


  @override
  void enableTurnStartEvent(GameController gameController) {
    // TODO: implement enableTurnStartEvent
    super.enableTurnStartEvent(gameController);
    this.gameController = gameController;
  }

    @override
  void OnPlayerTurn() { 
    if (enableEvent.isEmpty) {
      return;
    }
   final randomAiEvent = enableEvent[Random().nextInt(enableEvent.length)];

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
}