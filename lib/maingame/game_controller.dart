

import 'package:warx_flutter/maingame/event/ban_pick_event.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/maingame/state/ban_pick_state.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

enum GameTurn {
  beforestart,
  banpick,
  game
}

class GameController {

  GameTurn currentTurn = GameTurn.beforestart;
  BanPickGameState bp = BanPickGameState();
  Function? onRefresh;
  GameController() {
    _init();
  }

  void _init() {
    currentTurn = nextTurn(currentTurn); 
    start();
  }

  start() {
    if (currentTurn == GameTurn.banpick) {
      bp.setNextTurnCallback(() {
        currentTurn = GameTurn.game;
        onRefresh?.call();
      });
      bp.start();
    }
  }

  void onBanPickEvent(BanPickEvent event) {
    logD("onBanPickEvent $event");
    assert(currentTurn == GameTurn.banpick);
    bp.onEvent(event);
  }

  GameTurn nextTurn(GameTurn ct) {
    if (ct == GameTurn.beforestart) {
      return GameTurn.banpick;
    }
    assert(false);
    return ct;
  }

  PlayerInfo get playerA => PlayerInfo.playerA;
  PlayerInfo get playerB => PlayerInfo.playerB;

  void setRefresh(Function? callback) {
    onRefresh = callback;
  }

}