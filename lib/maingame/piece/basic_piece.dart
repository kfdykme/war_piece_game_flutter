import 'dart:async';
import 'dart:convert';

import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/event/base_game_event.dart';
import 'package:warx_flutter/maingame/event/piece_event.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/piece/archer_piece.dart';
import 'package:warx_flutter/maingame/piece/heavy_cavalry_piece.dart';
import 'package:warx_flutter/maingame/piece/lancer_piece.dart';
import 'package:warx_flutter/maingame/piece/light_cavalry_piece.dart';
import 'package:warx_flutter/maingame/piece/marksmen_piece.dart';
import 'package:warx_flutter/maingame/piece/reconnotire_piece.dart';
import 'package:warx_flutter/maingame/piece/spearmen_piece.dart';
import 'package:warx_flutter/maingame/piece/swordsman_piece.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/util/completer.safe.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

class MoveConfig {
  final int moveRange;
  MoveConfig(this.moveRange);
}

class PieceEventBuildData {
  List<BaseGameEvent> events = [];
  Completer<bool> completer = Completer();
}

class BasicPiece {
  final int index;
  final int maxAllowCount;
  // 已招募，不在手上的数量
  int currentAllowCount;
  // 当前
  int currentHandCount = 0;

  // 弃牌堆中的数量
  int disableCount = 0;

  // 本场游戏不能使用的数量
  int gameOutCount = 0;

  int hp = 0;
  String name;

  Function? nextClickCallback;
  BasicPiece(
      {required this.index,
      this.maxAllowCount = 5,
      this.currentAllowCount = 0,
      this.name = ''}) {
    this.name = this.name.isEmpty ? '$index' : this.name;
  }

  bool CanAfterAttack() {
    return false;
  }

  Future<bool> OnAfterAttack(GameController gameController) async {
    return returnDisableFuture();
  }

  void DoAttack(BasicPiece enemyPiece, LayoutNode node, GameController game) {
    enemyPiece.hp -= hp;
    enemyPiece.gameOutCount+= hp;
    if (enemyPiece.hp <= 0) {
      enemyPiece.hp = 0;
      node.piece = null;
    }
    enemyPiece.OnAttack(this, game);
  }

  void OnAttack(BasicPiece attackerPiece, GameController game) {
    logD("OnAttack");
  }
 

  static BasicPiece build(
      {required index, maxAllowCount = 4, currentAllowCount = 0, name = ''}) {
    if (index == 0) {
      return ArcherPiece(
          index: index,
          maxAllowCount: maxAllowCount,
          currentAllowCount: currentAllowCount,
          name: name);
    }
    if (index == 1) {
      return LancerPiece(
          index: index,
          maxAllowCount: maxAllowCount,
          currentAllowCount: currentAllowCount,
          name: name);
    }
    if (index == 2) {
      return HeavyCavalryPiece(
          index: index,
          maxAllowCount: maxAllowCount,
          currentAllowCount: currentAllowCount,
          name: name);
    }

    
    if (index == 3) {
      return ReconnotirePiece(
          index: index,
          maxAllowCount: 5,
          currentAllowCount: currentAllowCount,
          name: name);
    }

    if (index == 4) {
      return MarksmenPiece(
          index: index,
          maxAllowCount: maxAllowCount,
          currentAllowCount: currentAllowCount,
          name: name);
    }
    if (index == 5) {
      return LightCavalryPiece(
          index: index,
          maxAllowCount: maxAllowCount,
          currentAllowCount: currentAllowCount,
          name: name);
    }
    if (index == 6) {
      return SperamenPiece(
          index: index,
          maxAllowCount: maxAllowCount,
          currentAllowCount: currentAllowCount,
          name: name);
    }
    if (index == 7) {
      return SwordsmanPiece(
          index: index,
          maxAllowCount: maxAllowCount,
          currentAllowCount: currentAllowCount,
          name: name);
    }


    return BasicPiece(
        index: index,
        maxAllowCount: maxAllowCount,
        currentAllowCount: currentAllowCount,
        name: name);
  }

  int get enableEmpolyCount =>
      maxAllowCount -
      gameOutCount -
      currentAllowCount -
      currentHandCount -
      disableCount;

  @override
  String toString() {
    return jsonEncode(Map.from({
      'name': name,
      'index': index,
      'maxAllowCount': maxAllowCount,
      'currentAllowCount': currentAllowCount,
      'currentHandCount': currentHandCount,
      'disableCount': disableCount,
      'gameOutCount': gameOutCount,
    }));
  }

  @override
  // TODO: implement hashCode
  int get hashCode => index;
 

  void GetEnableAttackConfig() {}

  MoveConfig GetMoveConfig() {
    return MoveConfig(1);
  }

  PieceEventBuildData Move(GameController game) {
    logD("try Move "); 
    PieceEventBuildData data = PieceEventBuildData();
    Completer<bool> moveCompleter = Completer();
    // NOTE: 1 获取当前位置
    final layoutNode = GetCurrentLayoutNode(game);
  
    if (layoutNode != null) {
      // NOTE: 2 获取周围的格子中，可以被移动的格子 
      final sroundNodes = layoutNode.GetSroundedNodes(game: game, func: (LayoutNode node) {
        return node.piece == null;
      }, deep: GetMoveConfig().moveRange); 

      logD("sroundNodes ${sroundNodes.length}");
      sroundNodes.forEach((e) {
        final event = PieceMoveEvent();
        event.originNode = layoutNode;
        event.targetNode = e;
        event.playerId = GetPlayer(game).id;
        event.completer = moveCompleter;
        event.pieceId = index;
        data.events.add(event);
        e.nextClickCallback = () {
          logD("Do Move");
          game.OnEvent(event);
        };
      }); 
      game.onRefresh?.call();
    } else {
      logE("without piece ${this.name} in map");
    }

    moveCompleter.future.then((value) => data.completer.safeComplete(value));
    return data;
  }

  List<LayoutNode> GetNodesEnablePlaceNewPiece(GameController game) {
    final p = GetPlayer(game);
    return p.importantNodes;
  }

  LayoutNode? GetCurrentLayoutNode(GameController game) {
    return game.map.nodes.entries
        .where((element) => element.value.piece == this)
        .firstOrNull
        ?.value;
  }

  PlayerInfo GetPlayer(GameController game) {
    return game.playerA.selectAbleItem
            .where((element) => element == this)
            .isNotEmpty
        ? game.playerA
        : game.playerB;
  }

  List<LayoutNode> GetSroundedNodes(
      {int deep = 1, required GameController game, Function? func}) {
    final node = GetCurrentLayoutNode(game);
    if (node != null) {
      return node.GetSroundedNodes(deep: deep, game: game, func: func);
    }

    return [];
  }

  Future<bool> Attack(GameController game) async {
    logD("Attack ");
    Completer<bool> moveCompleter = Completer();
    // NOTE: 1 获取当前位置
    final layoutNodeEntry = game.map.nodes.entries
        .where((element) => element.value.piece == this)
        .firstOrNull;
    if (layoutNodeEntry != null) {
      // NOTE: 2 获取周围的格子中，可以被移动的格子
      final node = layoutNodeEntry.value;

      // NOTE: 3 找到对应的玩家
      final player = game.playerA.selectAbleItem
              .where((element) => element == this)
              .isNotEmpty
          ? game.playerA
          : game.playerB;

      final sroundNodes = game.map.nodes.entries
          .where((element) =>
              element.value.piece != null &&
              !player.selectAbleItem.contains(element.value.piece))
          .where((element) {
        // logD("sroundNodes ${element.key} ${ node.sroundNodeOffsets}");
        return node.sroundNodeOffsets.where((sOffset) {
          final comResult = sOffset - element.key;
          // logD("sroundNodes $comResult");
          return comResult.distance < 10;
        }).isNotEmpty;
      }).map((e) => e.value);
      logD("sroundNodes ${sroundNodes.length}");

      sroundNodes.forEach((e) {
        e.nextClickCallback = () {
          logD("Attack");
          final piece = e.piece;
          if (piece != null) {
           DoAttack(piece, e,game);
          }
          game.onRefresh?.call();
          moveCompleter.safeComplete(true);
        };
      });
      logD("${game.map.nodes.entries.where((e) {
        return e.value.nextClickCallback != null;
      })}");
      game.onRefresh?.call();
    } else {
      logE("without piece $this in map");
    }
    return moveCompleter.future;
  }

  Future<bool> Control(GameController gameController) {
    Completer<bool> completer = Completer();
    final layoutNodeEntry = gameController.map.nodes.entries
        .where((element) => element.value.piece == this)
        .firstOrNull;
    if (layoutNodeEntry != null) {
      if (layoutNodeEntry.value.isImportantNode) {
        // NOTE: 3 找到对应的玩家
        final player = gameController.playerA.selectAbleItem
                .where((element) => element == this)
                .isNotEmpty
            ? gameController.playerA
            : gameController.playerB;
        if (!player.importantNodes.contains(layoutNodeEntry.value)) {
          layoutNodeEntry.value.nextClickCallback = () {
            logD("Do Control");

            player.importantNodes.add(layoutNodeEntry.value);
            gameController.onRefresh?.call();
            completer.safeComplete(true);
          };
        }
      }
    }
    return completer.future;
  }

  Future<bool> Skill(GameController gameController) async {
    logD("Skill ");
    return returnDisableFuture();
  }

  bool CanAfterMove(GameController gameController) {
    return false;
  }

  Future<bool> AfterMove(GameController gameController) async {
    return false;
  }

  Map<String, dynamic> getConfig() {
    return {};
  }

  Future<bool> returnDisableFuture() {
    return Completer<bool>().future;
  }
}
