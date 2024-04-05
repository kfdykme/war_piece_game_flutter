
import 'package:warx_flutter/maingame/event/base_game_event.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/maingame/player/player_info_network.dart';

class NetworkBase {


  Future<void> OnEvent(BaseGameEvent baseGameEvent, PlayerInfo playerInfo) async {
    
    if (playerInfo is PlayerInfoNetwork) {
      final jsonString = BaseGameEventToString(baseGameEvent);
      playerInfo.channel.sink.add(jsonString);
    }
  }
}