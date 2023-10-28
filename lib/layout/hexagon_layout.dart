import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/util/color.random.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

class HexagonContainer extends StatefulWidget {
  final double? width;
  final double? height;

  const HexagonContainer({this.width, this.height});

  @override
  State<StatefulWidget> createState() {
    return HexagonContainerState();
  }
}

class HexagonContainerState extends State<HexagonContainer> {
  @override
  Widget build(BuildContext context) {
    logD("HexagonContainerState build");
    return Container(
      height: widget.height,
      width: widget.width,
      color: Color(0).randomColor(),
      child: LayoutBuilder(builder: (context, box) {
        return CustomPaint(
          foregroundPainter:
              HexagonMapPainter(size: Size(box.maxWidth, box.maxHeight)),
        );
      }),
    );
  }
}

const defaultRadius = 100.0;

class HexagonMapPainter extends CustomPainter {
  late LayoutNode originNode;
  final Size size;
  Map<Offset, LayoutNode> nodes = {};
  late Color hexagonColor;
  late Color importantColor;
  late double radius;
  HexagonMapPainter({double radius = defaultRadius, this.size = Size.zero}) {
    final comRadius = size.height / 6 / 2;
    final finalRadius = comRadius == 0 ? defaultRadius : comRadius;
    this.radius = finalRadius.floorToDouble();
    LayoutNode.globalId = 0;
    originNode = LayoutNode(this.radius);
    initData();
    initColor();
    logD("size.height / 2 ${size.height / 2}");
  }

  bool checkIsInMap(Offset offset ,List<Offset> list) {
    return list.where((element) => (element-offset).distance < radius).isNotEmpty;
  }

  void initData() {
    
    Queue<LayoutNode> nodesWaitForFetch = Queue();
    Map<Offset, int> nodesWaitForFetched = {};
    nodesWaitForFetch.add(originNode); 
    nodesWaitForFetched[originNode.locationOffset] = 1;
    var index = 0;
    functionCheckOrAdd(LayoutNode node) {
      // logD("functionCheckOrAdd ${node.id} ${node.locationOffset} ${node.radius} ${node.heightOffset}");
      if (!checkIsInMap(node.locationOffset, nodesWaitForFetched.keys.toList())) {
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
        (index++ < 10000) &&
        nodes.length < 100) {
      var cNode = nodesWaitForFetch.removeFirst();
      // logD("initData currentNode ${cNode.id} ${cNode.locationOffset}");
      functionCheckOrAdd(cNode);
      for (var offset in cNode.sroundNodeOffsets) {
        if (!checkOutOfMap(offset, cNode.radius)) {
          final nNode =
              LayoutNode(radius, locationOffset: offset);
          functionCheckOrAdd(nNode);
        }
      }
    }

    const safeNodesLength = 4 + 5 + 6 + 7 + 6 + 5 + 4;
    assert(safeNodesLength == nodes.length);
  }

  void initColor() {
    hexagonColor = Color(0).randomColor().withAlpha(100);
    importantColor =Color(0).randomColor().withAlpha(100);
  }

  Size getSafeSize(Size s1, Size s2) {
    return Size(max(s1.width, s2.width), max(s1.height, s2.height));
  }

  void _drawHexagon(LayoutNode node, Canvas canvas) {
    // logD("_drawHexagon ${node.locationOffset}");
    canvas.save();
    canvas.translate(node.locationOffset.dx, node.locationOffset.dy);
    Path path = Path();
    path.moveTo(node.arcNodeOffsets.first.dx, node.arcNodeOffsets.first.dy);
    for (var location in node.arcNodeOffsets) {
      path.lineTo(location.dx, location.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = node.isImportantNode ? importantColor : hexagonColor);
    if (kDebugMode) {
      var builder = ParagraphBuilder(ParagraphStyle(
          fontSize: 8, textHeightBehavior: TextHeightBehavior()))
        ..addText("${node.id}");
      canvas.drawParagraph(
          builder.build()..layout(ParagraphConstraints(width: 200)),
          Offset.zero);
    }
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final safeSize = getSafeSize(size ?? Size.zero, canvasSize);
    logD("paint $safeSize ${originNode.locationOffset}");
    // 1. translate
    canvas.translate(safeSize.width / 2, safeSize.height / 2);

    for (var node in nodes.values) {
      _drawHexagon(node, canvas);
    }
    // canvas.drawCircle(originNode.locationOffset, originNode.radius, Paint()..color = Color(0).randomColor());
    // originNode.sroundNodeOffsets.forEach((singleNode) {

    // canvas.drawCircle(singleNode, originNode.radius, Paint()..color = Color(0).randomColor());
    // });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    logD("shouldRepaint");
    return false;
  }

  bool checkOutOfMap(Offset locationOffset, double r) {
    final safeRadius = size.height / 2;
    bool isOutOfCircle =  (locationOffset.distance + r /2) > safeRadius;
    final safeRight = safeRadius * cos(pi / 6) ;
    bool isOutOfWidth = locationOffset.dx.abs() > safeRight;
    return isOutOfCircle || isOutOfWidth;
  }
}
