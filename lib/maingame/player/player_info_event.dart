
import 'dart:async';

import 'package:warx_flutter/maingame/event/base_game_event.dart';
import 'package:warx_flutter/maingame/player/player_info_network.dart';

class PlayerInfoEvent extends PlayerInfoNetwork {
  PlayerInfoEvent(super.id);


  @override
  Future<BaseGameEvent> GetNextRandomeGameEvent() async {
    
    final event = await getGameEventCompleter.future;
  

    // final enabledEvent = enableEvent.where((element) => element.type == event.type && element.pieceId == event.pieceId);

    getGameEventCompleter = Completer();
    return event;
  }
 

  @override
  String toString() {
    // TODO: implement toString
    return 'PlayerInfoEvent $playerId';
  }
}