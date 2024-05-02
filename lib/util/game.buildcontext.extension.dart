

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warx_flutter/maingame/game_controller.dart';

extension GameControllerExtension on BuildContext {

  
  ThemeData get theme => Theme.of(this);

  GameController get game => read<GameController>();
}