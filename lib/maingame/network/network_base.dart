
import 'package:warx_flutter/maingame/event/base_game_event.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/maingame/player/player_info_network.dart';
import 'package:warx_flutter/util/log.object.extension.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final String playerEnterPrefix = 'player enter ';

class NetworkBase {

  late WebSocketChannel channel;

  late GameController gameController;

  List<int> playingPlayer = [];

  Function? onPlayerJoin;


  Future<void> OnEvent(BaseGameEvent baseGameEvent, PlayerInfo playerInfo) async {
    logD("OnEvent");
    if (playerInfo is PlayerInfoNetwork) {
      final jsonString = BaseGameEventToString(baseGameEvent);
      logD("before send $jsonString");
      channel.sink.add(jsonString);
    }
  }

  void JoinPlayer(int playerId) {
    channel.sink.add("$playerEnterPrefix$playerId");
  }

  
  void initWebSocket() {
    logD("initWebSocket"); 
    
    final wsUrl = Uri.parse('ws://game.kfdykme.life');
    channel = WebSocketChannel.connect(wsUrl);

    channel.ready.then((value) {
      logD("initWebSocket success");
      channel.stream.listen((event) {
        if (event is String) {
          if (event.startsWith('\{')) {

            final gameEvent = StringToBaseGameEvent(event, gameController);
            if (gameEvent != null ) {
            final player = gameController.GetPlayerById(gameEvent.playerId);
              if (player != gameController.localPlayer) {

                gameController.OnEvent(gameEvent);
              } else {
                logD("receive message from ${player}");
              }
            }
          }
          if (event.startsWith(playerEnterPrefix)) {
            final playerId = event.substring(playerEnterPrefix.length);
            final playerIdInt = int.parse(playerId.trim());
            if (!playingPlayer.contains(playerIdInt)) {
              playingPlayer.add(playerIdInt);
            }
            onPlayerJoin?.call(playerIdInt);
            gameController.onRefresh?.call();
          }
        }
      }); 
    });

  }

  void bindOnPlayerJoin(Null Function(int playerId) param0) {
    onPlayerJoin = param0;
  }
}