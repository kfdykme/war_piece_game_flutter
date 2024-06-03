
import 'package:flutter/material.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/util/game.buildcontext.extension.dart';

class ChestLastItemList extends StatefulWidget {
  PlayerInfo info;
  ChestLastItemList(this.info);
  @override
  State<StatefulWidget> createState() {
    return ChestLastItemListState();
  }
}

class ChestLastItemListState extends State<ChestLastItemList> {

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,itemBuilder: (context,index) {
      return Container(color: widget.info.nextSkipCallback != null ? Colors.tealAccent : null,child: MaterialButton(onPressed: () async {
        final comsumePiece = await widget.info.nextSkipCallback?.call() ?? false;
        if (comsumePiece) {
          
          // context.game.nextPlayer();
        }
      }, child: Container(child: Text("Skip"),),),);
    },
    itemCount: 1,);
  }
}    