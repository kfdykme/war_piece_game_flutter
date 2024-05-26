

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
  Future<BaseGameEvent> GetNextRandomeGameEvent() async {
    
    final event = await getGameEventCompleter.future;
    logD("EventLoop getGameEventCompleter $event");
    return event;
  }
 

  @override
  void ComsupeEvent() {
    // TODO: implement ComsupeEvent
    super.ComsupeEvent();
    getGameEventCompleter = Completer();
  }

  @override
  String toString() {
    // TODO: implement toString
    return '远端玩家 $playerId ';
  }
}