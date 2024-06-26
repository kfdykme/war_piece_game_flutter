

import 'dart:math';
import 'dart:ui';
 
import 'package:flutter/material.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';
import 'package:warx_flutter/maingame/piece/gloden_piece.dart';
import 'package:warx_flutter/maingame/player/player_info_logic.ai.mixin.dart';
import 'package:warx_flutter/maingame/player/player_info_logic.ext.dart';
import 'package:warx_flutter/maingame/player/player_info_network.dart';
import 'package:warx_flutter/maingame/player/player_info_ui.ext.dart'; 
import 'package:warx_flutter/util/color.random.extension.dart';

const playerAId = 1000;
const playerBId = 2000;
class PlayerInfo with PlayerInfoUIExtension, PlayerInfoLogic  {



  // static PlayerInfo? playerInfoA;

  // static PlayerInfo get playerA  {
  //   return playerInfoA ??= PlayerInfo(playerAId);
  // }

  
  // static PlayerInfo? playerInfoB;
  // static PlayerInfo get playerB  {
  //   return playerInfoB ??= PlayerInfo(playerBId);
  // }

  final int id;
  late Color color;
  int turnCount = 0;
  bool isWinner = false;
  bool isWaitForAction = false;

  
  PlayerInfo(this.id) {
    if (id == playerAId) {
      color = Colors.redAccent;
    } else if (id == playerBId) {
      color = Colors.lightBlue;
    } else {
      color = Color.fromARGB(0, 129, 111, 111).randomColor().withAlpha(255);
    }
    SetPlayerId(id);
    SetColor(color);
  }





  String get name => "Player $id";

  @override
  String toString() {
    // TODO: implement toString
    return "Player $id";
  }
}