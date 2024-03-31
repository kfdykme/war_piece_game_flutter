
import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/event/base_game_event.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';

class PieceMoveEvent extends BaseGameEvent {
  late LayoutNode originNode;
  late LayoutNode targetNode;
}
class PieceAttackEvent extends BaseGameEvent {
  late BasicPiece attacker;
  late BasicPiece enemy;
  late LayoutNode enemyNode;
}