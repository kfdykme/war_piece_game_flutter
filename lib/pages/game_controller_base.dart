
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/util/state.extension.dart';

class GameControllerBase extends StatefulWidget {

  final Widget child;
  final int gameId;
  const GameControllerBase(this.child, this.gameId);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return GameControllerBaseState();
  }
}

class GameControllerBaseState extends State<GameControllerBase> {
  

  Widget? child ;
  
  GameController gameController = GameController();

  
  @override
  void initState() { 
    super.initState();
    child = widget.child;
    gameController.nextScene = (newWidget) {
      child = newWidget;
      setStateIfMounted();
    };
  }


  @override
  void didUpdateWidget(covariant GameControllerBase oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    child = widget.child;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      Provider.value(value: gameController)
    ], 
    child: child,);
  }
}