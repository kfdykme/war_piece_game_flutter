
import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/piece/basic_piece.dart';

class ReconnotirePiece extends BasicPiece {
  
  ReconnotirePiece ({required super.index, super.currentAllowCount, super.maxAllowCount, super.name});

  @override
  // TODO: implement name
  String get name => 'Reconnotire';


  @override
  List<LayoutNode> GetNodesEnablePlaceNewPiece(GameController game) {
    
    final List<LayoutNode> imnodes = [];
    imnodes.addAll( super.GetNodesEnablePlaceNewPiece(game));

    final p = GetPlayer(game);
    final allNodesWithFriendPiece = game.map.nodes.entries.where((element) => element.value.piece != null && p.selectAbleItem.contains(element.value.piece));
    allNodesWithFriendPiece.forEach((element) {
      final sNodes = element.value.GetSroundedNodes(game: game, func: (LayoutNode node) {
        return node.piece == null; // TODO: 是否需要判断能否在别人的基地出生
      });
      for (var sNode in sNodes) {
        if (!imnodes.contains(sNode)) {
          imnodes.add(sNode);
        }
      }
    });

    return imnodes;
  }
}