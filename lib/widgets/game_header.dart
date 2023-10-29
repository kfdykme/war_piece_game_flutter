

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/util/color.random.extension.dart';

class GameHeader extends StatefulWidget
 {
  final GameController controller;
  GameHeader({required this.controller});

  @override
  State<StatefulWidget> createState() {
    return GameHeaderState();
  }
 }

 class GameHeaderState extends State<GameHeader> {
   @override
  Widget build(BuildContext context) { 
    return Container(
    padding: EdgeInsets.all(8),
    child: Row(children: [
      Text("Ban/Pick 回合", style: TextStyle(color: Color(0).randomColor(), fontSize: 20),),
      // SvgPicture.asset('assets/images/map_base_circle.svg', color: Color(0).randomColor(), height: 50 , width: 50,)
    ],),);
  }
 }