import 'dart:collection';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:warx_flutter/layout/hexagon_draw.ext.dart';
import 'package:warx_flutter/layout/hexagon_nodes.mixin.dart';
import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/layout/reactable_hexagon_layout.dart';
import 'package:warx_flutter/resources/resource_manager.dart';
import 'package:warx_flutter/util/color.random.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

class HexagonContainer extends StatefulWidget {
  final double? width;
  final double? height; 
  const HexagonContainer({this.width, this.height});

  @override
  State<StatefulWidget> createState() {
    return ReactableHexagonLayout();
  }
}

class HexagonContainerState extends State<HexagonContainer> {

  HexagonMapPainter? painter;

  GlobalKey key = GlobalKey(debugLabel: 'HexagonContainerState');

  GlobalKey get getKey => key;


  HexagonMapPainter? getPainter({BoxConstraints? nbox}) {
    final box = nbox;
    if (box != null) {
      painter = HexagonMapPainter(
                size: Size(box.maxWidth, box.maxHeight));
               
    } 
    return painter;
  }


  @override
  Widget build(BuildContext context) {
    logD("HexagonContainerState build");
    return Container(
      height: widget.height,
      width: widget.width, 
      key: key,
      child: LayoutBuilder(builder: (context, box) {
        return CustomPaint(
          foregroundPainter: getPainter(nbox: box),
        );
      }),
    );
  }
}


class HexagonMapPainter extends CustomPainter with HexagonDrawExtension, HexagonNodesMixin{ 
  final Size size;
  late double radius;

  late PictureInfo mapBaseCircleInfo;

  Canvas? lastCanvas;

  HexagonMapPainter(
      {double radius = defaultRadius,
      this.size = Size.zero}) {
        
    mapBaseCircleInfo = ResourceManager.i.pictureInfo; 
    initData(size);
    initColor();
    initSvg();
    logD("size.height / 2 ${size.height / 2}");
  }

  Size getSafeSize(Size s1, Size s2) {
    return Size(max(s1.width, s2.width), max(s1.height, s2.height));
  }


  @override
  void paint(Canvas canvas, Size canvasSize) {
    final safeSize = getSafeSize(size ?? Size.zero, canvasSize);
    // logD("paint $safeSize ${originNode.locationOffset}");
    // 1. translate
    canvas.translate(safeSize.width / 2, safeSize.height / 2);

    for (var node in nodes.values) {
      drawHexagon(node, canvas);
    }
    // canvas.drawCircle(originNode.locationOffset, originNode.radius, Paint()..color = Color(0).randomColor());
    // originNode.sroundNodeOffsets.forEach((singleNode) {

    // canvas.drawCircle(singleNode, originNode.radius, Paint()..color = Color(0).randomColor());
    // });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    final old = oldDelegate as HexagonMapPainter;
    if (old.mapBaseCircleInfo == null && mapBaseCircleInfo != null) {
      return true;
    }
    return false;
  }


  @override
  bool? hitTest(ui.Offset position) {
    if (lastCanvas != null) {
      // lastCanvas
    }
    return super.hitTest(position);
  }
}
