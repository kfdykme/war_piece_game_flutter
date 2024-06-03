import 'package:flutter/material.dart';
import 'package:warx_flutter/maingame/game_controller.dart';

class EventLogWidget extends StatefulWidget {
  EventLogWidget(this.game);

  final GameController game;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EventLogState();
  }
}

class EventLogState extends State<EventLogWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      child: Container(
        height: 100,
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final e = widget.game.gameEventLog[index];
            return TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Text(
                        "$index ${e.toString()} ${e.playerId} ${widget.game.currentPlayer?.id} ${e.isFromNetwork ? '(Net)':'(Local)'}",)
                  ],
                ));
          },
          itemCount: widget.game.gameEventLog.length,
        ),
      ),
    );
  }
}
