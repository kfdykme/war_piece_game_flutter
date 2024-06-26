import 'package:warx_flutter/maingame/event/base_game_event.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/maingame/player/player_info_network.dart';
import 'package:warx_flutter/util/completer.safe.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final String playerEnterPrefix = 'player enter ';
final String joinGamePrefix = 'joinGame';

class NetworkBase {
  late WebSocketChannel channel;

  late GameController gameController;

  List<int> playingPlayer = [];

  Function? onPlayerJoin;

  int currentPlayer = -1;

  Future<void> OnEvent(BaseGameEvent baseGameEvent,
      PlayerInfo playerInfo) async {
    logD("PlayerInfoNetwork OnEvent");
    if (playerInfo is! PlayerInfoNetwork) {
      final jsonString =
          BaseGameEventToString(baseGameEvent);
      logD("send PlayerInfoNetwork $jsonString");
      channel.sink.add(jsonString);
    }
  }

  void JoinPlayer(int playerId) {
    currentPlayer = playerId;
    channel.sink.add("$playerEnterPrefix$playerId");
  }

  void JoinGame() {
    channel.sink.add('$joinGamePrefix');
  }

  void initWebSocket() {
    logD("initWebSocket");

    final wsUrl = Uri.parse('ws://game.kfdykme.life');
    channel = WebSocketChannel.connect(wsUrl);

    channel.ready.then((value) {
      logD("initWebSocket success");
      channel.stream.listen((event) {
        logD("receive message ${currentPlayer}  $event");
        if (event is String) {
          if (event.startsWith('\{')) {
            final gameEvent = StringToBaseGameEvent(
                event, gameController);
            if (gameEvent != null) {
              final player = gameController.GetPlayerById(
                  gameEvent.playerId);
              if (player != gameController.localPlayer &&
                  player is PlayerInfoNetwork) {
                player.getGameEventCompleter
                    .safeComplete(gameEvent);
              } else {}
            }
          }

          if (event.startsWith(joinGamePrefix)) {
            JoinPlayer(currentPlayer);
          }

          if (event.startsWith(playerEnterPrefix)) {
            final playerId =
                event.substring(playerEnterPrefix.length);
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

  void bindOnPlayerJoin(
      Null Function(int playerId) param0) {
    onPlayerJoin = param0;
  }
}
