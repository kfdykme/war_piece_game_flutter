import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/event/base_game_event.dart';
import 'package:warx_flutter/maingame/event/event_completer.dart';
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
  int currentPackageCount;

  // 当前
  int currentHandCount = 0;

  // 弃牌堆中的数量
  int disableCount = 0;

  // 本场游戏不能使用的数量
  int gameOutCount = 0;

  int hp = 0;
  String name;

  Function? nextClickCallback;

  Color? color;
  BasicPiece(
      {required this.index,
      this.maxAllowCount = 5,
      this.currentPackageCount = 0,
      this.name = ''}) {
    this.name = this.name.isEmpty ? '$index' : this.name;
  }

  bool CanAfterAttack() {
    return false;
  }

  PieceEventBuildData OnAfterAttack(
      GameController gameController) {
    return PieceEventBuildData();
  }

  void DoAttack(BasicPiece enemyPiece, LayoutNode node,
      GameController game) {
    logD("DoAttack $this -> $enemyPiece");
    final outCount = min(hp, enemyPiece.hp);
    enemyPiece.hp -= hp;
    enemyPiece.gameOutCount += outCount;
    if (enemyPiece.hp <= 0) {
      enemyPiece.hp = 0;
      node.piece = null;
    }
    enemyPiece.OnAttack(this, game);
  }

  void OnAttack(
      BasicPiece attackerPiece, GameController game) {
    logD("OnAttack $this");
  }

  static BasicPiece build(
      {required index,
      maxAllowCount = 4,
      currentPackageCount = 0,
      name = ''}) {
    var piece;
    if (index == 0) {
      piece = ArcherPiece(
          index: index,
          maxAllowCount: maxAllowCount,
          currentPackageCount: currentPackageCount,
          name: name);
    }
    if (index == 1) {
      piece = LancerPiece(
          index: index,
          maxAllowCount: maxAllowCount,
          currentPackageCount: currentPackageCount,
          name: name);
    }
    if (index == 2) {
      piece = HeavyCavalryPiece(
          index: index,
          maxAllowCount: maxAllowCount,
          currentPackageCount: currentPackageCount,
          name: name);
    }

    if (index == 3) {
      piece = ReconnotirePiece(
          index: index,
          maxAllowCount: 5,
          currentPackageCount: currentPackageCount,
          name: name);
    }

    if (index == 4) {
      piece = MarksmenPiece(
          index: index,
          maxAllowCount: maxAllowCount,
          currentPackageCount: currentPackageCount,
          name: name);
    }
    if (index == 5) {
      piece = LightCavalryPiece(
          index: index,
          maxAllowCount: maxAllowCount,
          currentPackageCount: currentPackageCount,
          name: name);
    }
    if (index == 6) {
      piece = SperamenPiece(
          index: index,
          maxAllowCount: maxAllowCount,
          currentPackageCount: currentPackageCount,
          name: name);
    }
    if (index == 7) {
      piece = SwordsmanPiece(
          index: index,
          maxAllowCount: maxAllowCount,
          currentPackageCount: currentPackageCount,
          name: name);
    }

    piece ??= BasicPiece(
        index: index,
        maxAllowCount: maxAllowCount,
        currentPackageCount: currentPackageCount,
        name: name);

    return piece;
  }

  int enableEmpolyCount = 0;

  @override
  String toString() {
    assert(enableEmpolyCount >= 0);
    assert(maxAllowCount ==
        enableEmpolyCount +
            gameOutCount +
            disableCount +
            currentPackageCount +
            currentHandCount +
            hp);
    return jsonEncode(Map.from({
      'name': name,
      'index': index,
      'maxAllowCount': maxAllowCount,
      'currentPackageCount': currentPackageCount,
      'currentHandCount': currentHandCount,
      'disableCount': disableCount,
      'gameOutCount': gameOutCount,
      'enableEmpolyCount': enableEmpolyCount,
      'hp': hp,
    }));
  }

  @override
  // TODO: implement hashCode
  int get hashCode => index;

  void GetEnableAttackConfig() {}

  MoveConfig GetMoveConfig() {
    return MoveConfig(1);
  }

  PieceEventBuildData BuildMoveAction(GameController game) {
    logD("try BuildMoveAction ");
    PieceEventBuildData data = PieceEventBuildData();
    Completer<bool> moveCompleter = Completer();
    // NOTE: 1 获取当前位置
    final layoutNode = GetCurrentLayoutNode(game);

    if (layoutNode != null) {
      // NOTE: 2 获取周围的格子中，可以被移动的格子
      final sroundNodes = layoutNode.GetSroundedNodes(
          game: game,
          func: (LayoutNode node) {
            return node.piece == null;
          },
          deep: GetMoveConfig().moveRange);

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
      logE("try BuildMoveAction fail: without piece ${this.name} in map");
    }

    moveCompleter.future.then(
        (value) => data.completer.safeComplete(value));
    return data;
  }

  List<LayoutNode> GetNodesEnablePlaceNewPiece(
      GameController game) {
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
      {int deep = 1,
      required GameController game,
      Function? func}) {
    final node = GetCurrentLayoutNode(game);
    if (node != null) {
      return node.GetSroundedNodes(
          deep: deep, game: game, func: func);
    }

    return [];
  }

  PieceEventBuildData Attack(GameController game) {
    logD("Attack ");
    PieceEventBuildData data = PieceEventBuildData();
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
              !player.selectAbleItem
                  .contains(element.value.piece))
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
        final enemy = e.piece;
        if (enemy != null) {
          final event = PieceAttackEvent();
          event.pieceId = index;
          event.playerId = GetPlayer(game).id;
          event.completer = moveCompleter;
          event.attacker = this;
          event.enemy = enemy;
          event.enemyNode = e;
          data.events.add(event);
          e.nextClickCallback = () {
            logD("Attack");
            game.OnEvent(event);
          };
        }
      });
      logD("${game.map.nodes.entries.where((e) {
        return e.value.nextClickCallback != null;
      })}");
      game.onRefresh?.call();
    } else {
      logE("without piece $this in map");
    }
    moveCompleter.future.then(
        (value) => data.completer.safeComplete(value));
    return data;
  }

  PieceEventBuildData Control(
      GameController gameController) {
    PieceEventBuildData data = PieceEventBuildData();
    Completer<bool> completer = Completer();
    data.completer = completer;
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
        if (!player.importantNodes
            .contains(layoutNodeEntry.value)) {

          ControlEvent controlEvent = ControlEvent();
          controlEvent.playerId = player.id;
          controlEvent.pieceId = index;
          controlEvent.nodeId = layoutNodeEntry.value.id;
          controlEvent.completer = data.completer;
          data.events.add(controlEvent);
          layoutNodeEntry.value.nextClickCallback = () {
            logD("Do Control $this");
            gameController.OnEvent(controlEvent);
          };
        }
      }
    }
    return data;
  }

  PieceEventBuildData Skill(GameController gameController) {
    logD("Skill ");
    return PieceEventBuildData();
  }

  bool CanAfterMove(GameController gameController) {
    return false;
  }

  PieceEventBuildData AfterMove(
      GameController gameController) {
    return PieceEventBuildData();
  }

  Map<String, dynamic> getConfig() {
    return {};
  }

  Future<bool> returnDisableFuture() {
    return Completer<bool>().future;
  }
}
