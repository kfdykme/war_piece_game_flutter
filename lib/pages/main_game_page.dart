import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:warx_flutter/layout/hexagon_layout.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/resources/resource_manager.dart';
import 'package:warx_flutter/util/game.buildcontext.extension.dart';
import 'package:warx_flutter/util/state.extension.dart';
import 'package:warx_flutter/widgets/game_ban_pick.dart';
import 'package:warx_flutter/widgets/game_header.dart';
import 'package:warx_flutter/widgets/game_player_info.dart';

class MainGamePage extends StatefulWidget {
  const MainGamePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MainGamePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MainGamePage> {
  int _counter = 0;

  bool isReady = false;
  @override
  void initState() { 
    super.initState();

    ResourceManager.i.loadImage();
    ResourceManager.i.ready.then((value) {
      isReady = true;
      setStateIfMounted();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    context.game.setRefresh(() {
      setStateIfMounted();
    });
    if (!isReady) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: <Widget>[
          HexagonContainer(
              width: size.width, height: size.height / 2),
          GameHeader(
              controller: context.read<GameController>()),
          Container(
              margin: EdgeInsets.only(top: size.height / 2),
              color: Theme.of(context).hintColor,
              width: size.width,
              height: size.height / 2,
              child: Row(
                children: [
                  if (context.game.currentTurn ==
                      GameTurn.banpick)
                    GameBanPick(
                        controller:
                            context.read<GameController>())
                  else if (context.game.currentTurn ==
                      GameTurn.game)
                    GamePlayerInfoContainer(),
                ],
              ))
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
