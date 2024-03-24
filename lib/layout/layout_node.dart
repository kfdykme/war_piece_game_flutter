

import 'dart:math';
import 'dart:ui';

import 'package:warx_flutter/maingame/piece/basic_piece.dart';
import 'package:warx_flutter/util/log.object.extension.dart';


/// 360 / 6 = 60
/// 60 / 2 =30
/// 60 度的等腰三角形 就是等边三角形
/// 六边形的边长是 和圆形半径一样
/// 六边形从圆心到右边顶点的距离是r， 
/// 六边形从圆形到顶边中点的距离是cos(30) * r
const circleRadius = 10;  
const borderWidth = 3;
class LayoutNode {

    double radius = circleRadius.toDouble();
    double heightOffset = 0;
    double rightOffset = 0;
    List<Offset> sroundNodeOffsets = [];
    List<Offset> arcNodeOffsets = [];
    Offset locationOffset;

    BasicPiece? piece;
 
    late int id;

    static int globalId = 0;

    bool get isImportantNode => [60, 44, 108,6, 35,89,3,76,69,14].where((e) => e == id).isNotEmpty;

    bool get isPlayerABasicImportant => [60, 44].where((element) => element == id).isNotEmpty;

    bool get isPlayerBBasicImportant => [89, 76].where((element) => element == id).isNotEmpty;

    bool get isClickAble => nextClickCallback != null;

    Function? nextClickCallback;

    Future<bool> onClick() {
      if (nextClickCallback != null) {
        final result = nextClickCallback?.call();
        nextClickCallback = null;
        return Future.value(result);
      }
      return Future.value(false);
    }


    LayoutNode(this.radius, { this.locationOffset = Offset.zero}) {
        _init();
        // isClickAble = Random().nextBool();
    }

    Path get boxPath {
      
      Path path = Path();
      path.moveTo(arcNodeOffsets.first.dx, arcNodeOffsets.first.dy);
      for (var location in arcNodeOffsets) {
        path.lineTo(location.dx, location.dy);
      }
      path.close();
      return path;
    } 

    void _init() {
      id = globalId++;
      // id所代表的位置是永远固定的

       heightOffset =  cos( pi / 6) * radius;
       rightOffset = radius / 2;

      

       sroundNodeOffsets.add(Offset(0, heightOffset * 2) + locationOffset);
      //  logD("_init $id ${sroundNodeOffsets.first} $locationOffset");
       sroundNodeOffsets.add(Offset(1.5 * radius, heightOffset ) + locationOffset);
       sroundNodeOffsets.add(Offset(radius * 1.5, -1 * heightOffset) + locationOffset);
       sroundNodeOffsets.add(Offset(0,-2 * heightOffset) + locationOffset);
       sroundNodeOffsets.add(Offset(-1.5 * radius, heightOffset * -1) + locationOffset);
       sroundNodeOffsets.add(Offset(radius * -1.5, heightOffset * 1) + locationOffset);
        sroundNodeOffsets = sroundNodeOffsets.map((e) {
          return Offset(e.dx.floorToDouble(), e.dy.floorToDouble());
        }).toList();
       // 顶点左边
       final arcRadius = radius - borderWidth;
       final arcHeightOffset =  cos( pi / 6) * arcRadius;
       final arcRightOffset = arcRadius / 2;
       arcNodeOffsets.add(Offset(arcRadius, 0));  
       arcNodeOffsets.add(Offset(arcRightOffset, -1 * arcHeightOffset));  
       arcNodeOffsets.add(Offset(arcRightOffset * -1,  -1 * arcHeightOffset));  
       arcNodeOffsets.add(Offset(arcRadius * -1, 0));  
       arcNodeOffsets.add(Offset(arcRightOffset * -1, arcHeightOffset));  
       arcNodeOffsets.add(Offset(arcRightOffset, arcHeightOffset));
    }
}