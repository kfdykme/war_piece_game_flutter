
import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/event/base_game_event.dart';

class PieceMoveEvent extends BaseGameEvent {
  late LayoutNode originNode;
  late LayoutNode targetNode;
}