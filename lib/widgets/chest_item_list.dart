

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/maingame/player/player_info_ui.ext.dart';
import 'package:warx_flutter/resources/chest_resource_manager.dart';
import 'package:warx_flutter/resources/resource_manager.dart';
import 'package:warx_flutter/util/game.buildcontext.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';
import 'package:warx_flutter/widgets/builder/chest_item_builder.dart';

class ChestItemList extends StatefulWidget {
  final PlayerInfo info;
  ChestItemList(PlayerInfo this.info) {

  }
  
  @override
  State<StatefulWidget> createState() {
    return ChestItemListState();
  }

  
}

class ChestItemListState extends State<ChestItemList> {
  @override
  Widget build(BuildContext context) {

    final list = widget.info.selectAbleItem.where((element) => element.currentHandCount>0).toList();
 
    return  ListView.separated(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == list.length) {
          return MaterialButton(onPressed: () {
        logD("getRandom ${widget.info.getNextRandomPieces()}");
        widget.info.notifyRefresh();
    }, child: Text("Get Random Piece"),);
        }

        final piece = list[index];
        final size = 40.0;
      return MaterialButton(onPressed: () {
          widget.info.onClickPiece(piece);
      }, child: Container(
        child:
        Row(children: [
          Container(
            margin: const EdgeInsets.all(8),
            child: piece.index == -1 ? ChestItemBuilder().buildIconWithData(
          ResourceManager.i.getImage(10, 25)
          , size: size) : ChestItemBuilder().buildIcon(piece.index, size: size),
          ),
          Text("x ${piece.currentHandCount}")
        ],),)
      );
    }, separatorBuilder: (context, index) {
      return Container();
    }, itemCount: list.length + 1);
  }
}