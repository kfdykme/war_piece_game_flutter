

import 'package:flutter/material.dart'; 
import 'package:warx_flutter/util/color.random.extension.dart';

const playerAId = 1000;
const palyerBId = 2000;
class PlayerInfo {


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
    color = Color(0).randomColor().withAlpha(255);
  }

  String get name => "Player $id";
}