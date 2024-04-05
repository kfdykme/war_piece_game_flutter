

import 'dart:io';

import 'package:warx_flutter/maingame/event/base_game_event.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/util/log.object.extension.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PlayerInfoNetwork extends PlayerInfo {
  PlayerInfoNetwork(super.id);

  late GameController gameController; 

  late WebSocketChannel channel;

  @override
  void enableTurnStartEvent(GameController gameController) {
    logD("EventLoop enableTurnStartEvent $this");
    // TODO: implement enableTurnStartEvent
    super.enableTurnStartEvent(gameController);
    this.gameController = gameController;

    initWebSocket();
  }

  void initWebSocket() {
    logD("initWebSocket");
    var host = '127.0.0.1';
    if (Platform.isAndroid) {
      host = '192.168.31.190';
    }
    final wsUrl = Uri.parse('ws://$host:3012');
    final channel = WebSocketChannel.connect(wsUrl);

    channel.ready.then((value) {
      channel.stream.listen((event) {
        if (event is String && event.startsWith('\{')) {

          final gameEvent = StringToBaseGameEvent(event);
          if (gameEvent != null) {
            gameController.OnEvent(gameEvent);
          }
        }
      }); 
    });

  }
}