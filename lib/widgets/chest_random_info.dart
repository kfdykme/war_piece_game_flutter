import 'package:flutter/material.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/resources/resource_manager.dart';
import 'package:warx_flutter/util/game.buildcontext.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';
import 'package:warx_flutter/widgets/builder/chest_item_builder.dart';

class ChestRandomInfo extends StatefulWidget {
  final PlayerInfo info;
  ChestRandomInfo(this.info);

  @override
  State<StatefulWidget> createState() {
    return ChestRandomInfoState();
  }
}

class ChestRandomInfoState extends State<ChestRandomInfo> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          Widget? child = null;
          final item = (widget.info.selectAbleItem[index]);
          child = _buildPiece(item);
          return Container(
            height: 100,
            child: child,
          );
        },
        itemCount: widget.info.selectAbleItem.length,
      ),
    );
  }

  Widget _buildPiece(BasicPiece piece) {
    final size = 24.0;


    bool enableClick = piece.nextClickCallback != null;
    return GestureDetector(onTap: () async  {
      final comsumePiece =  await piece.nextClickCallback?.call() ?? false;
      if (comsumePiece) {
        context.game.nextPlayer();
      }
      logD("on pay piece $comsumePiece");
    },child: Container(
      color: enableClick ? Colors.tealAccent : null,
      child:  Flex(
      direction: Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      children: [
        piece.index == -1 ? ChestItemBuilder().buildIconWithData(
          ResourceManager.i.getImage(10, 25)
          , size: size) : ChestItemBuilder().buildIcon(piece.index, size: size),
        Text("${piece.name} x ${enableClick ? piece.enableEmpolyCount : piece.currentAllowCount} ")
      ],
    ),),);
  }
}
