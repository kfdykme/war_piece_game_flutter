

import 'package:warx_flutter/maingame/game_controller.dart';

class BasicGamePlugin {

  late GameController host;
  BasicGamePlugin();

  bindController(GameController c) {
    host = c;
  }
}