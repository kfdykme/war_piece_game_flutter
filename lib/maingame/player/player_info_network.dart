

import 'dart:async';
import 'dart:io';

import 'package:warx_flutter/maingame/event/base_game_event.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/maingame/player/player_info_logic.ai.mixin.dart';
import 'package:warx_flutter/util/log.object.extension.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PlayerInfoNetwork extends PlayerInfoAi {
  PlayerInfoNetwork(super.id);

  late GameController gameController; 

  Completer<BaseGameEvent> getGameEventCompleter = Completer();

  @override
  void enableTurnStartEvent(GameController gameController) {
    logD("EventLoop enableTurnStartEvent $this");
    // TODO: implement enableTurnStartEvent
    super.enableTurnStartEvent(gameController);
    this.gameController = gameController;
    
  }


  @override
  Future<BaseGameEvent> GetNextRandomeGameEvent() {
    getGameEventCompleter = Completer();
    return getGameEventCompleter.future;
  }

  @override
  Future<void> OnPlayerTurn() {
     
    return super.OnPlayerTurn();
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'PlayerEnableNetwork $playerId';
  }
}