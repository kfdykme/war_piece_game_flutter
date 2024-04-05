
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/maingame/player/player_info_ui.ext.dart';
import 'package:warx_flutter/util/color.random.extension.dart';
import 'package:warx_flutter/util/game.buildcontext.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';
import 'package:warx_flutter/util/size.buildcontext.extension.dart';
import 'package:warx_flutter/widgets/chest_item_list.dart';
import 'package:warx_flutter/widgets/chest_last_item_list.dart';
import 'package:warx_flutter/widgets/chest_random_info.dart';
import 'package:warx_flutter/widgets/statefull_widget_update.ext.dart';

class GamePlayerInfoContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GamePlayerInfoContainterState();
  }
}

class GamePlayerInfoContainterState extends State<GamePlayerInfoContainer> {
  @override
  Widget build(BuildContext context) {
    final size = context.mSize();
    return Container(width: size.width, height: size.height, child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GamePlayerInfoSingleItem(context.game.playerA),
        GamePlayerInfoSingleItem(context.game.playerB),
      ],) ,);
  }
}

class GamePlayerInfoSingleItem extends StatefulWidget{

  final PlayerInfo info;
  GamePlayerInfoSingleItem(this.info);

  @override
  State<StatefulWidget> createState() {
    return GamePlayerInfoSingleItemState();
  }
}

class GamePlayerInfoSingleItemState extends State<GamePlayerInfoSingleItem> {


     

  @override
  void initState() {
    super.initState();

    widget.info.bindUpdate((){
      updateState();
    });
  }

  @override
  void didUpdateWidget(covariant GamePlayerInfoSingleItem oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    widget.info.bindUpdate(() {
      updateState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = context.mSize();
    final width = (size.width - size.height) / 2;

    final isCurrentActivePlayer = context.game.currentPlayer == widget.info;
    logD("Player ${widget.info.id} is current $isCurrentActivePlayer");
    return Container(color: widget.info.color, width: width, height: size.height - 100,
    child:
      Column(children: [
        // TITLE
        Text("${widget.info.id} ", style: TextStyle(fontWeight: FontWeight.w600, color: widget.info.color),),
        // Status
        Text("${widget.info.name} ${isCurrentActivePlayer ? 'ING' : ''} ${widget.info.turnCount}"),
        Text("${widget.info.isWinner ? 'WINNER' : ''}"),
        ChestRandomInfo(widget.info),
        ChestItemList(widget.info),
        // Expanded(child: Container()),
        // ChestLastItemList(widget.info)
      ])
    ,);
  } 
}