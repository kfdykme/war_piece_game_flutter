

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warx_flutter/maingame/game_controller.dart';

extension GameControllerExtension on BuildContext {
  GameController get game => read<GameController>();
}