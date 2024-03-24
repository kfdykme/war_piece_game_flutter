

import 'dart:math';

import 'package:warx_flutter/maingame/event/ban_pick_event.dart';
import 'package:warx_flutter/maingame/map/hexagon_map.dart';
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

  static bool dev_is_skip_bp = true;

  HexagonMap map = HexagonMap();

  PlayerInfo? currentPlayer;

  GameController() {
    _init();
  }

  void _init() {

    map.bindController(this);

    currentTurn = nextTurn(currentTurn); 
    start();
  }

  start() {
    if (currentTurn == GameTurn.banpick) {
      bp.setNextTurnCallback(() {
        // fill player info

        playerA.fillPieces(bp.playerASelected);
        playerB.fillPieces(bp.playerBSelected); 
        playerA.bindNotifyUI(playerA.notifyRefresh);
        playerB.bindNotifyUI(playerB.notifyRefresh);
        currentTurn = GameTurn.game;
        onRefresh?.call();
      });
      if (!dev_is_skip_bp) {
        bp.start();
      } else {
        playerA.fillPieces([0,1,2,3]);
        playerB.fillPieces([4,5,6,7]);
        playerA.bindNotifyUI(playerA.notifyRefresh);
        playerB.bindNotifyUI(playerB.notifyRefresh);
        
        currentTurn = GameTurn.game;
        nextPlayer();
        onRefresh?.call();
      }
    }
  }

  void nextPlayer() {
    if (currentPlayer == null) {
      // TODO: 默认开始
      currentPlayer = playerA;
    } else if (currentPlayer == playerA){
      currentPlayer = playerB;
    } else if (currentPlayer == playerB) {
      currentPlayer = playerA;
    }
    playerA.notifyRefresh();
    playerB.notifyRefresh();
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