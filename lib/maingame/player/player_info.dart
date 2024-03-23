

import 'dart:math';
import 'dart:ui';
 
import 'package:flutter/material.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';
import 'package:warx_flutter/maingame/piece/gloden_piece.dart';
import 'package:warx_flutter/maingame/player/player_info_logic.ext.dart';
import 'package:warx_flutter/maingame/player/player_info_ui.ext.dart'; 
import 'package:warx_flutter/util/color.random.extension.dart';

const playerAId = 1000;
const palyerBId = 2000;
class PlayerInfo with PlayerInfoUIExtension, PlayerInfoLogic {



  static PlayerInfo? playerInfoA;
  static PlayerInfo get playerA  {
    return playerInfoA ??= PlayerInfo(playerAId);
  }

  
  static PlayerInfo? playerInfoB;
  static PlayerInfo get playerB  {
    return playerInfoB ??= PlayerInfo(palyerBId);
  }

  final int id;
  late Color color;
  bool isWaitForAction = false;
  PlayerInfo(this.id) {
    if (id == playerAId) {
      color = Colors.redAccent;
    } else if (id == palyerBId) {
      color = Colors.lightBlue;
    } else {
      color = Color.fromARGB(0, 129, 111, 111).randomColor().withAlpha(255);
    }
  }



  String get name => "Player $id";

}