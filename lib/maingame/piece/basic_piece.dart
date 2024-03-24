
import 'dart:async';
import 'dart:convert';

import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/util/completer.safe.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

class MoveConfig {
  final int moveRange;
  MoveConfig(this.moveRange);
}

class BasicPiece {
  final int index;
  final int maxAllowCount;
  int currentAllowCount;
  int currentHandCount = 0;
  // 弃牌堆中的数量
  int disableCount = 0;

  // 本场游戏不能使用的数量
  int gameOutCount = 0;
  int hp = 0;
  final String name;

  Function? nextClickCallback;
  BasicPiece({
    required this.index ,
    this.maxAllowCount = 5,
    this.currentAllowCount = 0,
    this.name = ''
  });

  int get enableEmpolyCount => maxAllowCount - gameOutCount - currentAllowCount - currentHandCount - disableCount;

  @override
  String toString() {
    return jsonEncode(Map.from({
      'name':name,
      'index':index,
      'maxAllowCount':maxAllowCount,
      'currentAllowCount':currentAllowCount,
      'currentHandCount':currentHandCount,
    }));
  }
  @override
  // TODO: implement hashCode
  int get hashCode => index;


  MoveConfig GetEnableMoveConfig() {
    return _DefaultNormalMoveConfig();
  }

  void GetEnableAttackConfig() {

  }

  Future<bool> Move(GameController game) async {
    logD("Move ");
    final config = GetEnableMoveConfig();

    Completer<bool> moveCompleter = Completer();
    // NOTE: 1 获取当前位置
    final layoutNodeEntry = game.map.nodes.entries.where((element) => element.value.piece == this).firstOrNull;
    if (layoutNodeEntry != null) {
      // NOTE: 2 获取周围的格子中，可以被移动的格子
      final node = layoutNodeEntry.value;
      final sroundNodes = game.map.nodes.entries.where((element)  {
        
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
          node.piece = null;
          e.piece = this;
          game.onRefresh?.call();
          moveCompleter.safeComplete(true);
        };
      });
      logD("${ game.map.nodes.entries.where((e) { return e.value.nextClickCallback != null; })}");
      game.onRefresh?.call();
    } else {
      logE("without piece $this in map");
    }

    return moveCompleter.future;
  }

  void Attack() {
    logD("Attack ");
  }

  void Skill() {
    logD("Skill ");
  }
  
  MoveConfig _DefaultNormalMoveConfig() {
    return MoveConfig(1);
  }
}