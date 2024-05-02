import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/util/color.random.extension.dart';
import 'package:warx_flutter/util/game.buildcontext.extension.dart';
import 'package:warx_flutter/util/size.buildcontext.extension.dart';

class GameHeader extends StatefulWidget {
  final GameController controller;
  GameHeader({required this.controller});

  @override
  State<StatefulWidget> createState() {
    return GameHeaderState();
  }
}

class GameHeaderState extends State<GameHeader> {
  String currentTurnTitle() {
    if (context.game.currentTurn == GameTurn.banpick) {
      return "Ban/Pick";
    }
    return "${context.game.currentTurnPlayer}";
  }

  Widget _buildSinglePlayer(PlayerInfo info) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: info.color,
      ),
      // width: context.mSize().width / 4,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      height: 25,
      // margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(child: Text(info.name, style: TextStyle(color: info.isWaitForAction ? Colors.red :  Colors.white),),),
    );
  }

  Widget buildPlayerInfo() {
    return Container(
      child: Row(children: [
        _buildSinglePlayer(context.game.playerA),
        _buildSinglePlayer(context.game.playerB)
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "${currentTurnTitle()} 回合",
            style: TextStyle(color: Color(0).randomColor(), fontSize: 20),
          ),
          buildPlayerInfo()
          // SvgPicture.asset('assets/images/map_base_circle.svg', color: Color(0).randomColor(), height: 50 , width: 50,)
        ],
      ),
    );
  }
}
