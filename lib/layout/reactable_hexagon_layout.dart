

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:warx_flutter/layout/hexagon_draw.ext.dart';
import 'package:warx_flutter/layout/hexagon_layout.dart';
import 'package:warx_flutter/layout/hexagon_nodes.mixin.dart';
import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/resources/chest_resource_manager.dart';
import 'package:warx_flutter/util/color.random.extension.dart';
import 'package:warx_flutter/util/game.buildcontext.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';
import 'package:warx_flutter/util/state.extension.dart';

class ReactableHexagonLayout extends State<HexagonContainer>{

  Offset centerOffset = Offset.zero;

  List<Offset> hitOffsets = [];
  
  ReactableHexagonLayout() {
  }
  
  @override
  void initState() {
    super.initState();
    context.game.playerA.bindUpdate(() {
      setStateIfMounted();
    });
    context.game.playerB.bindUpdate(() {
      setStateIfMounted();
    }); 
  }

  Map<Offset,LayoutNode> get nodes {
     return context.game.map.nodes;
  }

  @override
  Widget build(BuildContext context) { 
    return GestureDetector( 
      onTapUp:(details) async {  
        final hitNode = nodes.values.where((node) => node.boxPath.contains(details.globalPosition - centerOffset - node.locationOffset)).firstOrNull;
        if (hitNode != null) {
          logD("$hitNode");
          // hitNode.isClickAble = !hitNode.isClickAble;
          hitNode.onClick().then((comsumePiece) {
            if (comsumePiece) {

            }
          });

          setStateIfMounted();
        } else {
          // hitOffsets.add(details.globalPosition);
          // setStateIfMounted();
          // logD("hitOffsets $hitOffsets");
        }
      },
      child: Container(
      height: widget.height,
      width: widget.width,  
      color: Colors.transparent,
      child: LayoutBuilder(builder: (context, box) {
        centerOffset = Offset(box.maxWidth/2, box.maxHeight/2); 
        context.game.map.initData(Size(box.maxWidth, box.maxHeight));
      
        return Stack(
          children: [
            ...(nodes.entries.map((entry)  {
              final key = entry.key;
              final node = entry.value;
              return CustomPaint(
                
                painter: SingleHexagonPainter(offset: key, node: node, centerOffset:centerOffset, gameController: context.game),
                foregroundPainter: HitTestPainter(offsets: hitOffsets, gameController: context.game),
                child: Container(width: 20, height: 20,),
              );
            }).toList() ?? [])
          ]
        );
      }),
    ),
    );
  }
}

class HitTestPainter extends CustomPainter {

  final List<Offset> offsets;


  GameController gameController;

  HitTestPainter({this.offsets = const [], required this.gameController});

  @override
  void paint(Canvas canvas, Size size) {
    offsets.forEach((element) {
      
    canvas.drawCircle(element, 30, Paint()..color = Color(0).randomColor());
    });
  }

  @override
  bool shouldRepaint(covariant HitTestPainter oldDelegate) {
    return oldDelegate.offsets.length == offsets.length;
  }
  
}

class SingleHexagonPainter extends CustomPainter with HexagonDrawExtension  {
  final Offset offset;
  final LayoutNode node;
  final Offset centerOffset;

  static Color? _hex;
  static Color get color {
    return _hex ??= Color(0).randomColor();
  }
  static Color? _hex2;
  static Color get color2 {
    return _hex2 ??= Color(0).randomColor();
  }
  GameController gameController;

  SingleHexagonPainter({required this.offset, required this.node, this.centerOffset = Offset.zero, required this.gameController}) {
    initSvg();
    Color imageColor = color2;
    if (node.isPlayerABasicImportant || gameController.playerA.importantNodes.contains(node)) {
      imageColor = PlayerInfo.playerA.color;
    }
    if (node.isPlayerBBasicImportant|| gameController.playerB.importantNodes.contains(node)) {
      imageColor = PlayerInfo.playerB.color;
    }
    initColor(hexagon: color, image:imageColor,  important: Colors.teal);
  }
  


  Size getSafeSize(Size s1, Size s2) {
    return Size(max(s1.width, s2.width), max(s1.height, s2.height));
  }
  @override
  void paint(Canvas canvas, Size canvasSize) {
    // TODO: implement paint
    // final safeSize = getSafeSize(canvasSize ?? Size.zero, canvasSize);
    // logD("paint $safeSize ${originNode.locationOffset}");
    // 1. translate
    canvas.translate(centerOffset.dx, centerOffset.dy);

    canvas.save();
    // canvas.translate(offset.dx, offset.dy);
    // canvas.drawCircle(Offset.zero, 30, Paint()..color = Colors.black26);
    drawHexagon(node, canvas);
    canvas.restore();

  }

  @override
  bool shouldRepaint(covariant SingleHexagonPainter oldDelegate) {
    return true;
  }


  @override
  bool? hitTest(Offset position) {
    // TODO: implement hitTest
    return super.hitTest(position);
  }
}