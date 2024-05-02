import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:warx_flutter/maingame/event/base_game_event.dart';
import 'package:warx_flutter/maingame/event/event_completer.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/maingame/player/player_info_event.dart';
import 'package:warx_flutter/maingame/player/player_info_network.dart';
import 'package:warx_flutter/maingame/player/player_info_ui.ext.dart';
import 'package:warx_flutter/resources/chest_resource_manager.dart';
import 'package:warx_flutter/resources/resource_manager.dart';
import 'package:warx_flutter/util/game.buildcontext.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';
import 'package:warx_flutter/widgets/builder/chest_item_builder.dart';

class ChestItemList extends StatefulWidget {
  final PlayerInfo info;

  ChestItemList(PlayerInfo this.info) {}

  @override
  State<StatefulWidget> createState() {
    return ChestItemListState();
  }
}

class ChestItemListState extends State<ChestItemList> {
  @override
  Widget build(BuildContext context) {
    final list = widget.info.selectAbleItem
        .where((element) => element.currentHandCount > 0)
        .toList();
    if (list.isEmpty) {
      widget.info.getNextRandomPieces();
      Future.delayed( Duration.zero).then((value) => widget.info.notifyRefresh());
    }
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (index == list.length) {
            return MaterialButton(
              onPressed: () {
                logD("getRandom ${widget.info.getNextRandomPieces()}");
                widget.info.notifyRefresh();
              },
              child: Text("Get Random Piece"),
            );
          }

          final piece = list[index];
          final size = 40.0;
          return MaterialButton(
              onPressed: () {
                if (context.game.currentPlayer == widget.info &&
                    widget.info.enable(OnClickPieceEvent())) {
                  // widget.info.onClickPiece(piece, context.game).then((value) {
                  //   if (value) {
                  //     context.game.nextPlayer();

                  //   }
                  // });
                  if (widget.info is PlayerInfoEvent) {
                    final event = widget.info.enableEvent.where((element) => element is OnClickPieceEvent).firstOrNull;
                    if (event != null) {
                      event.pieceId = piece.index;
                      event.playerId = widget.info.id; 
                      context.game.OnEvent(event);
                    }
                  } else {

                    final event = OnClickPieceEvent();
                    event.pieceId = piece.index;
                    event.playerId = widget.info.id;  
                    context.game.OnEvent(event);
                  }
                }
              },
              child: Container(
                color: widget.info.enable(OnClickPieceEvent())
                    ? Colors.tealAccent
                    : null,
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: piece.index == -1
                          ? ChestItemBuilder().buildIconWithData(
                              ResourceManager.i.getImage(10, 25),
                              size: size)
                          : ChestItemBuilder()
                              .buildIcon(piece.index, size: size),
                    ),
                    Text("${piece.name} x ${piece.currentHandCount}")
                  ],
                ),
              ));
        },
        separatorBuilder: (context, index) {
          return Container();
        },
        itemCount: list.length);
  }
}
