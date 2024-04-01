import 'dart:async';
import 'dart:math';

import 'package:warx_flutter/maingame/event/ban_pick_event.dart';
import 'package:warx_flutter/maingame/event/base_game_event.dart';
import 'package:warx_flutter/maingame/event/piece_event.dart';
import 'package:warx_flutter/maingame/map/hexagon_map.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/maingame/state/ban_pick_state.dart';
import 'package:warx_flutter/util/completer.safe.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

enum GameTurn { beforestart, banpick, game }

class GameController {
  GameTurn currentTurn = GameTurn.beforestart;
  BanPickGameState bp = BanPickGameState();
  Function? onRefresh;
  Completer onReadyPlayerComplter = Completer();

  static bool dev_is_skip_bp = true;

  HexagonMap map = HexagonMap();

  PlayerInfo? _currentPlayer;

  set currentPlayer(v) {
    if (_currentPlayer != null) {
      _currentPlayer?.enableEvent.clear();
    }
    _currentPlayer = v;
    if (_currentPlayer != null) {
      _currentPlayer?.enableTurnStartEvent(this);
    }
  }

  get currentPlayer => _currentPlayer;

  GameController() {
    _init();
  }

  void _init() {
    map.bindController(this);

    currentTurn = nextTurn(currentTurn);
    start();
  }

  PlayerInfo GetPlayerById(int id) {
    if (id == playerA.id) {
      return playerA;
    } else if (id == playerB.id) {
      return playerB;
    }
    throw Error();
  }

  void OnEvent(BaseGameEvent event) {
    final player = GetPlayerById(event.playerId);
    final safePiece = player.GetPieceByIndex(event.pieceId);
    
    logD("EventLoop OnEvent $event ${safePiece?.name}");
    if (event is OnClickPieceEvent) {
      final safePiece = player.GetPieceByIndex(event.pieceId);
      if (safePiece != null) {
        player.onClickPiece(safePiece, this).then((value) {
          logD("onClickPiece result $value");
          nextPlayer();
        });
      }
      return;
    } else if (event is ArragePieceEvent) {
      final node = map.nodes.entries.where((element) => element.value.id == event.nodeId).firstOrNull?.value;
      if (node != null && safePiece != null) {
        if ((node.piece == null && safePiece.hp == 0) || node.piece == safePiece) {
          if (node.piece != null && node.piece != safePiece) {
            logD("already has piece here");
            event.completer.safeComplete(false);
          } else {
            logD("add to here");
            safePiece.hp += 1;
            assert(safePiece.enableEmpolyCount >0 );
            safePiece.enableEmpolyCount -= 1;
            node.piece = safePiece;

            event.completer.safeComplete(true);
            player.comsumePiece(safePiece);
          }
        }
      }
    } else if (event is RecruitPieceEvent) {
      final safePiece = player.GetPieceByIndex(event.pieceId);
      if(safePiece != null) {
        safePiece.currentPackageCount++;
        player.comsumePiece(safePiece);
        event.completer.safeComplete(true);
      }
    } else if (event is SkipEvent) {
      if (safePiece != null) {
        player.comsumePiece(safePiece);
        event.completer.safeComplete(true);
      } else {
        event.completer.safeComplete(true);
      }
    } else if (event is PieceMoveEvent) {
      if (safePiece != null) {
        event.originNode.piece = null;
        event.targetNode.piece = safePiece;
        onRefresh?.call();
        event.completer.safeComplete(true);
      }
    } else if (event is PieceAttackEvent) {
      if (safePiece != null) {
        event.attacker.DoAttack(event.enemy, event.enemyNode, this);
        onRefresh?.call();
        event.completer.safeComplete(true);
      }
    }

    if (!event.completer.isCompleted) {
      logE("EventLoop Not Complete $event $safePiece");
    }
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
        playerA.fillPieces([0, 1, 2, 3]);
        playerB.fillPieces([4, 5, 6, 7]);
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
    } else if (currentPlayer == playerA) {
      currentPlayer = playerB;
    } else if (currentPlayer == playerB) {
      currentPlayer = playerA;
    }
    playerA.notifyRefresh();
    playerB.notifyRefresh();
    currentPlayer.OnPlayerTurn();
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
