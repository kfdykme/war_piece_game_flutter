import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:warx_flutter/layout/layout_node.dart';
import 'package:warx_flutter/resources/chest_resource_manager.dart';
import 'package:warx_flutter/resources/resource_manager.dart';
import 'package:warx_flutter/util/color.random.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

mixin HexagonDrawExtension {
  ui.Image? mapBaseCircleInfoImage;

  late Color imageColor;

  late Color hexagonColor;
  late Color importantColor;

  // final PictureInfo? mapBaseCircleInfo;

  void initSvg() async {
    mapBaseCircleInfoImage =
        ResourceManager.i.pictureInfo.picture.toImageSync(1024, 1024);
  }

  void initColor({Color? hexagon, Color? important, Color? image}) {
    hexagonColor = hexagon ?? Color(0).randomColor().withAlpha(100);
    importantColor = important ?? Color(0).randomColor().withAlpha(100);
    imageColor = image ?? Color(0).randomColor().withAlpha(200);
  }

  void drawHexagonBaseImage(LayoutNode node, Canvas canvas) {
    if (node.isImportantNode) {
      final safeImage = mapBaseCircleInfoImage;
      final safeCount = canvas.getSaveCount();
      if (safeImage != null) {
        canvas.save();
        canvas.translate(node.locationOffset.dx - node.heightOffset,
            node.locationOffset.dy - node.heightOffset);
        final size = node.heightOffset * 2;
        final margin = size / 10;
        canvas.saveLayer(
            Offset.zero & Size(size, size),
            Paint()
              ..colorFilter = ColorFilter.mode(imageColor, BlendMode.srcIn));

        canvas.drawImageNine(
            safeImage,
            Rect.zero,
            Rect.fromLTRB(margin, margin, size - margin, size - margin),
            Paint());

      }
      canvas.restoreToCount(safeCount);
    }
  }

  void drawLocationPiece(LayoutNode node, Canvas canvas) {

    canvas.save();
    canvas.translate(node.locationOffset.dx - node.heightOffset,
        node.locationOffset.dy - node.heightOffset);
    final safePiece = node.piece;
    if (safePiece != null) {
      final image = ChestResourceManager.i.getUiImageByIndex(safePiece.index, () {
        // TODO: NOTIFY REFRESH
      });
      if (image != null) {
        final size = node.heightOffset * 2;
        final margin = size / 10;
         
        canvas.drawImageNine(
            image,
            Rect.zero,
            Rect.fromLTRB(margin, margin, size - margin, size - margin),
            Paint());
         
      }
    }
    canvas.restore();
    
    if (safePiece != null) {
      canvas.save();
      canvas.translate(node.locationOffset.dx, node.locationOffset.dy);
      var builder = ParagraphBuilder(
          ParagraphStyle(fontSize: 16, textHeightBehavior: TextHeightBehavior()))
        ..addText("${safePiece.name} ${safePiece.hp}");
      canvas.drawParagraph(
          builder.build()..layout(ParagraphConstraints(width: 200)),
          Offset.zero);
      canvas.restore();
    }
  }

  void drawHexagon(LayoutNode node, Canvas canvas) {
    // logD("drawHexagon ${node.locationOffset}");

    var currentHexagonColor = hexagonColor;
    if (node.isClickAble) {
      currentHexagonColor = Colors.tealAccent;
    }
    
    final safePiece = node.piece;
    if (safePiece != null && safePiece.color != null) {
      currentHexagonColor = safePiece.color!;
    }
    canvas.save();
    canvas.translate(node.locationOffset.dx, node.locationOffset.dy);
    canvas.drawPath(node.boxPath, Paint()..color = currentHexagonColor);
    // Path shadowPath = Path();
    // final ps = [2,3,4];
    // shadowPath.moveTo(node.arcNodeOffsets[ps.first].dx, node.arcNodeOffsets[ps.first].dy);
    // for(var index in ps){
    //   var location = node.arcNodeOffsets[index];
    //    shadowPath.lineTo(location.dx, location.dy);
    // }
    // for(var index in ps.reversed) {

    //   var location = node.arcNodeOffsets[index];
    //    shadowPath.lineTo(location.dx, location.dy);
    // }
    // canvas.drawPath(shadowPath,Paint()..color = Colors.black ..strokeWidth = 3);

    canvas.restore();
    drawHexagonBaseImage(node, canvas);
    drawLocationPiece(node, canvas);
    // if (kDebugMode) {
    //   canvas.save();
    //   canvas.translate(node.locationOffset.dx, node.locationOffset.dy);
    //   var builder = ParagraphBuilder(
    //       ParagraphStyle(fontSize: 16, textHeightBehavior: TextHeightBehavior()))
    //     ..addText("${node.id}");
    //   canvas.drawParagraph(
    //       builder.build()..layout(ParagraphConstraints(width: 200)),
    //       Offset.zero);
    //   canvas.restore();
    // }
  }
}
