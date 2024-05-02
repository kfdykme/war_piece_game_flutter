

import 'dart:math';

import 'package:warx_flutter/maingame/event/ban_pick_event.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

import '../player/player_info.dart';
import '../turn/next_turn_mixin.dart';


class BanPickInnerState {
  final bool isBan;
  int count;
  final int playerId;
  BanPickInnerState({this.isBan = false, this.count = 1, this.playerId = playerAId});
}

class BanPickGameState with NextTurnMixin {

  List<BanPickInnerState> innerStates = [];

  int stateIndex = 0;

  List<int> banedItemLists = [];
  List<int> playerASelected = [];
  List<int> playerBSelected = [];
  BanPickGameState() {
    _init();
  }

  

  void _init() {
    innerStates.add(BanPickInnerState(isBan: true, playerId: playerAId));
    innerStates.add(BanPickInnerState(isBan: true, playerId: playerBId));
    innerStates.add(BanPickInnerState(playerId: playerAId)); 
    innerStates.add(BanPickInnerState(playerId: playerBId, count: 2)); 
    innerStates.add(BanPickInnerState(playerId: playerAId, count: 2)); 
    innerStates.add(BanPickInnerState(playerId: playerBId, count: 2)); 
    innerStates.add(BanPickInnerState(playerId: playerAId));  
  }

  void start() async {
    // currentState.
  }

  void onEvent(BanPickEvent event) {
    logD("EventLoop ${event.index}");
    final safeState = innerStates[stateIndex];
    if (safeState.isBan) {  
      logD("EventLoop banedItemLists");
      banedItemLists.add(event.index);
      stateIndex ++;
    }
    if (!safeState.isBan) {
      logD("EventLoop select");
      // select
      if (safeState.playerId == playerAId) {
        playerASelected.add(event.index);
      } 
      if (safeState.playerId == playerBId) {
        playerBSelected.add(event.index);
      } 

      safeState.count -= 1;
      if (safeState.count == 0) {
        stateIndex ++;
      }
    }

    if (stateIndex >= innerStates.length) {
      notifyNextTurn();
    }
  }
}