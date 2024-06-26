import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/resources/chest_resource_manager.dart';
import 'package:warx_flutter/resources/resource_manager.dart';
import 'package:warx_flutter/util/color.random.extension.dart';
import 'package:warx_flutter/util/game.buildcontext.extension.dart';
import 'package:warx_flutter/util/size.buildcontext.extension.dart';
import 'package:warx_flutter/util/state.extension.dart';

import '../maingame/event/ban_pick_event.dart';

class GameBanPick extends StatefulWidget {
  GameController controller;
  GameBanPick({required this.controller});

  @override
  State<StatefulWidget> createState() {
    return GameBanPickState();
  }
}

class GameBanPickState extends State<GameBanPick> {
  @override
  Widget build(BuildContext context) {
    final size = context.mSize();
    const margin = 50;
    return Center(
      child: Container(
        height: size.height - margin - margin,
        width: size.width,
        color: Color(0).randomColor(),
        child: Wrap(
          direction: Axis.horizontal,
          children: [
            ...[0,1,2,3,4,5,6,7,8,9].map((e) => GameBanPickItem(
                  width: size.width / 5,
                  height: (size.height - margin * 2) / 2,
                  index: e,
                ))
          ],
        ),
      ),
    );
  }
}

class GameBanPickItem extends StatefulWidget {
  final double width;
  final double height;
  final int index;
  const GameBanPickItem(
      {super.key, this.width = 0, this.height = 0, this.index = -1});

  @override
  State<StatefulWidget> createState() {
    return GameBanPickItemSate();
  }
}

class GameBanPickItemSate extends State<GameBanPickItem> {
  
  Widget _buildSelectedPlayerInfo(PlayerInfo info) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white.withAlpha(100)),
      padding: EdgeInsets.all(4),
      child:Center(child:  Text("${info.name} selected", style: TextStyle(color: info.color),),));
  }

  Widget _innerBuildGameBanPickItem(int index) {

    final isBaned = context.game.bp.banedItemLists.contains(index);
 

    final isSelectedByA = context.game.bp.playerASelected.contains(index);
    final isSelectedByB = context.game.bp.playerBSelected.contains(index);

    Color borderColor = Colors.white;
    double borderWidth = 8;
    PlayerInfo? selectedPlayerInfo;
    if (isSelectedByA) {
      borderColor = context.game.playerA.color;
      borderWidth = 8;
      selectedPlayerInfo = context.game.playerA;
    }
    if (isSelectedByB) {
      borderColor = context.game.playerB.color;
      borderWidth = 8;
      selectedPlayerInfo = context.game.playerB;
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border:  Border.all(color: borderColor, width: borderWidth, ),
          color: isBaned ? Colors.red : Color(0).randomColor()),
      child: MaterialButton(onPressed: () {
        if (!isBaned) {
          context.game.onBanPickEvent(BanPickEvent(index));
          setStateIfMounted();
        }
      }, child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [if (selectedPlayerInfo != null) _buildSelectedPlayerInfo(selectedPlayerInfo),
          if (isBaned) _buildBandInfo(),
          _buildIcon(index)
         ],
      ),),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: _innerBuildGameBanPickItem(widget.index),
    );
  }
  
  Widget _buildBandInfo() {
    return Text("Baned");
  }
  
  Widget _buildIcon(int index) {

    
    return Container(
      width: 100,
      height: 100,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(ChestResourceManager.i.chestDataByIndex(index),
      fit: BoxFit.cover, ),
      ),
    
      // child: Image.asset('resources/kenney_1-bit-pack/Tilemap/tileset_legacy.png',
      // fit: BoxFit.none,),
    );
  }
}

