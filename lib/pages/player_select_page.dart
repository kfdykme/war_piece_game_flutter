
import 'package:flutter/material.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/maingame/player/player_info_network.dart';
import 'package:warx_flutter/pages/main_game_page.dart';
import 'package:warx_flutter/util/game.buildcontext.extension.dart';

class PlayerSelectPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PlayerSelectPageState();
  }
}

class PlayerSelectPageState extends State<PlayerSelectPage> {

  Widget buildButton(String p) {
    return 	ElevatedButton(
  style: ButtonStyle(
    foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
    overlayColor: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.hovered))
          return Theme.of(context).primaryColor.withOpacity(0.04);
        if (states.contains(MaterialState.focused) ||
            states.contains(MaterialState.pressed))
          return Theme.of(context).primaryColor.withOpacity(0.12);
        return null; // Defer to the widget's default.
      },
    ),
  ),
  onPressed: () { 
    onSelectPlayer(p);
  },
  child: Text('我是玩家${p}')
);
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
     buildButton('A'),
          const SizedBox(height: 30),
     buildButton('B')
    ],));
  }

  void onSelectPlayer(String p) {
    if (p == 'A') {
      PlayerInfo.playerInfoA = PlayerInfoNetwork(playerAId);
      PlayerInfo.playerInfoB = PlayerInfoNetwork(palyerBId);
      context.game.localPlayer = PlayerInfo.playerA;
    } else if (p == 'B') {
      PlayerInfo.playerInfoA = PlayerInfoNetwork(playerAId);
      PlayerInfo.playerInfoB = PlayerInfoNetwork(palyerBId);
      context.game.localPlayer = PlayerInfo.playerB;
    }

    PlayerInfo.playerA.fillPieces([0, 1, 2, 3]);
    PlayerInfo.playerB.fillPieces([4, 5, 6, 7]);
    PlayerInfo.playerA.bindNotifyUI(PlayerInfo.playerA.notifyRefresh);
    PlayerInfo.playerB.bindNotifyUI(PlayerInfo.playerB.notifyRefresh);

    context.game.currentPlayer = null;
    context.game.nextPlayer();

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const MainGamePage(title:"");
    }));
  }
}