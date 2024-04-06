import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:warx_flutter/maingame/event/event_completer.dart';
import 'package:warx_flutter/maingame/event/piece_event.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/util/log.object.extension.dart';


enum GameEventType {
  unknown,
  click,
  recuit,
  arrage,
  skip,
  control,
  move,
  attack
}
class BaseGameEvent {
  int playerId = 0;
  int pieceId = 0;
  int type = 0;
  Completer<bool> completer = Completer();

  @override
  String toString() {
    // TODO: implement toString
    return runtimeType.toString();
  }
}

class OnClickPieceEvent extends BaseGameEvent{
  
}

class RecruitPieceEvent extends BaseGameEvent { 
  int targetPieceId = 0;
}

class ArragePieceEvent extends BaseGameEvent {
  int nodeId = 0;
}

class SkipEvent extends BaseGameEvent {
  
}

class ControlEvent extends BaseGameEvent {
  int nodeId = 0;
}

String BaseGameEventToString(BaseGameEvent baseGameEvent) {
  Map<String,dynamic> maps = {};
  maps['playerId'] = baseGameEvent.playerId;
  maps['pieceId'] = baseGameEvent.pieceId;
  maps['completerId'] = EventCompleter.GetCompleterId(baseGameEvent.completer);
  assert(maps['completerId'] >= 0);
  if (baseGameEvent is ControlEvent) {
    maps['nodeId'] = baseGameEvent.nodeId;
    maps['type'] = GameEventType.control.index;
  } else if (baseGameEvent is ArragePieceEvent) {
    maps['nodeId'] = baseGameEvent.nodeId;
    maps['type'] = GameEventType.arrage.index;
  } else if (baseGameEvent is OnClickPieceEvent) {
    maps['type'] = GameEventType.click.index;
  } else if (baseGameEvent is RecruitPieceEvent) {
    maps['targetPieceId'] = baseGameEvent.targetPieceId;
    maps['type'] = GameEventType.recuit.index;
  } else if (baseGameEvent is SkipEvent) {
    maps['type'] = GameEventType.skip.index;
  } else if (baseGameEvent is PieceMoveEvent) {
    maps['type'] = GameEventType.move.index;
    maps['originNode'] = baseGameEvent.originNode.id;
    maps['targetNode'] = baseGameEvent.targetNode.id;
  } else if (baseGameEvent is PieceAttackEvent) {
    maps['type'] = GameEventType.attack.index;
    maps['attacker'] = baseGameEvent.attacker.index;
    maps['enemy'] = baseGameEvent.enemy.index;
    maps['enemyNode'] = baseGameEvent.enemyNode.id;
  }


  if(kDebugMode) {
    maps['runtimeType'] = baseGameEvent.runtimeType.toString();
  }
  return jsonEncode(maps);
}

BaseGameEvent? StringToBaseGameEvent(String baseGameEventString,GameController gameController) {
  try {
    final maps = jsonDecode(baseGameEventString);
    final typeInt = maps['type'] as int;
    final type = GameEventType.values[typeInt];
    final completerId = maps['completerId']  as int;
    final complter = EventCompleter.GetCompleterById<bool>(completerId);
    BaseGameEvent? event;
    if (type == GameEventType.click) {
      OnClickPieceEvent onClickPieceEvent = OnClickPieceEvent();
      event = onClickPieceEvent;
    } else if(type == GameEventType.arrage) {
      ArragePieceEvent arragePieceEvent = ArragePieceEvent();
      arragePieceEvent.nodeId = maps['nodeId'];
      event = arragePieceEvent;
    } else if (type == GameEventType.move) {
      PieceMoveEvent pieceMoveEvent = PieceMoveEvent();
      final originNodeId = maps['originNode'];
      final targetNodeId = maps['targetNode'];
      pieceMoveEvent.originNode = gameController.map.nodes.entries.where((element) => element.value.id == originNodeId ).first.value;
      pieceMoveEvent.targetNode = gameController.map.nodes.entries.where((element) => element.value.id == targetNodeId ).first.value;
      event = pieceMoveEvent;
    }

    event?.playerId = maps['playerId'] as int;
    event?.pieceId = maps['pieceId'] as int;
    event?.completer = complter;
    return event;
  } catch (e) {
    baseGameEventString.logE('StringToBaseGameEvent $e');
  }
  return null;
}