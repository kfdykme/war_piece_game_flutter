

import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:warx_flutter/layout/layout_node.dart';

const defaultRadius = 100.0;
mixin HexagonNodesMixin {
  
  Size size = Size.zero;
  double radius = defaultRadius;
  Map<Offset, LayoutNode> nodes = {};

  late LayoutNode originNode;

  bool checkOutOfMap(Offset locationOffset, double r) {
    final safeRadius = size.height / 2;
    bool isOutOfCircle = (locationOffset.distance + r / 2) > safeRadius;
    final safeRight = safeRadius * cos(pi / 6);
    bool isOutOfWidth = locationOffset.dx.abs() > safeRight;
    return isOutOfCircle || isOutOfWidth;
  }


  bool checkIsInMap(Offset offset, List<Offset> list) {
    return list
        .where((element) => (element - offset).distance < radius)
        .isNotEmpty;
  }

  void initData(Size initSize) {
    size = initSize;
    final comRadius = size.height / 6 / 2;
    final finalRadius = comRadius == 0 ? defaultRadius : comRadius;
    radius = finalRadius.floorToDouble();
    LayoutNode.globalId = 0;
    originNode = LayoutNode(this.radius);
    Queue<LayoutNode> nodesWaitForFetch = Queue();
    Map<Offset, int> nodesWaitForFetched = {};
    nodesWaitForFetch.add(originNode);
    nodesWaitForFetched[originNode.locationOffset] = 1;
    var index = 0;
    functionCheckOrAdd(LayoutNode node) {
      // logD("functionCheckOrAdd ${node.id} ${node.locationOffset} ${node.radius} ${node.heightOffset}");
      if (!checkIsInMap(
          node.locationOffset, nodesWaitForFetched.keys.toList())) {
        // logD("functionCheckOrAdd ${node.id} add to queue");
        nodesWaitForFetch.add(node);
        nodesWaitForFetched[node.locationOffset] = 1;
      }
      if (!checkIsInMap(node.locationOffset, nodes.keys.toList())) {
        // logD("functionCheckOrAdd ${node.id} add to map");
        nodes[node.locationOffset] = node;
      }
    }

    while (nodesWaitForFetch.isNotEmpty &&
        nodes.length < 100) {
      var cNode = nodesWaitForFetch.removeFirst();
      // logD("initData currentNode ${cNode.id} ${cNode.locationOffset}");
      functionCheckOrAdd(cNode);
      for (var offset in cNode.sroundNodeOffsets) {
        if (!checkOutOfMap(offset, cNode.radius)) {
          final nNode = LayoutNode(radius, locationOffset: offset);
          functionCheckOrAdd(nNode);
        }
      }
    }

    const safeNodesLength = 4 + 5 + 6 + 7 + 6 + 5 + 4;
    assert(safeNodesLength == nodes.length);
  }

}