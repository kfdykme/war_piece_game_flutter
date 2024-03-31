
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:warx_flutter/util/log.object.extension.dart';



  const _size = 543 / 32;
class ResourceManager {
  
  late ui.Image image;

  static ResourceManager? _i;

  static ResourceManager get i => _i ??= ResourceManager();

  Completer<bool> readyCompleter = Completer();

  Future<bool> get ready => readyCompleter.future;

  List<ByteData> singleImages = [];

  ResourceManager() {
    loadImage();
  }

  // loadImageItem
  int loadImagePosX = 0;
  int loadImagePosY = 0;
  final double singleImageItemWidth = _size;//100 ~/ 6;
  final double singleImageItemHeight = _size;// 100 ~/ 6;

  int imageWidth = 0;
  int imageHeight = 0;

  int row = 0;
  int colum = 0;

  late PictureInfo pictureInfo;
  Future<void> loadImage() async {
    // rootBundle.loadBuffer(key)
    Uint8List imageBytes = Uint8List.fromList([]);
    if (Platform.isWindows) {

      File imageFile = File('resources/kenney_1-bit-pack/Tilemap/tileset_legacy.png');
      imageFile.statSync();
      imageBytes = await imageFile.readAsBytes();
    } else if (Platform.isMacOS) {
      final bytes = await rootBundle.load('resources/kenney_1-bit-pack/Tilemap/tileset_legacy.png');
      imageBytes = bytes.buffer.asUint8List();
    }
    logD("loadImage size ${imageBytes.length}");

    ui.Image originalImage = await decodeImageFromList(imageBytes);
    image = originalImage;

    imageWidth = image.width;
    imageHeight = image.height;
    logD("loadImage w $imageWidth h $imageHeight");

    row = imageWidth ~/ singleImageItemWidth;
    colum = imageHeight ~/ singleImageItemHeight;
    logD("loadImage row $row column $colum");
    singleImages = [];
    loadSingleImage();

    
    pictureInfo = await vg
        .loadPicture(
            const SvgAssetLoader(
              "assets/images/map_base_circle.svg",
            ),
            null);
  }

  Uint8List getImage(x, y){
    final pos = x + y * colum;
    return singleImages[pos].buffer.asUint8List();
  }

  Future<void> loadSingleImage() async {
    // logD("loadSingleImage $loadImagePosX,$loadImagePosY");

    ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas canvas = ui.Canvas(recorder);

    final padding = 0;

    canvas.drawImageRect(image, ui.Rect.fromLTWH(loadImagePosX * singleImageItemWidth.toDouble() + padding,
    loadImagePosY * singleImageItemHeight.toDouble(), singleImageItemWidth.toDouble(), singleImageItemHeight.toDouble()),
      ui.Rect.fromLTWH(0 * singleImageItemWidth.toDouble(),
    0 * singleImageItemHeight.toDouble(), singleImageItemWidth.toDouble(), singleImageItemHeight.toDouble()),
    ui.Paint());
    ui.ColorFilter colorFilter = ui.ColorFilter.mode(Color(0xff714560), ui.BlendMode.src); 
    // canvas.saveLayer(null, Paint()..colorFilter = colorFilter);
    // canvas.drawRect(ui.Rect.fromLTWH(0 * singleImageItemWidth.toDouble(),
    // 0 * singleImageItemHeight.toDouble(), singleImageItemWidth.toDouble(), singleImageItemHeight.toDouble()), Paint()..color = Colors.pinkAccent);

    ui.Picture picture = recorder.endRecording();

    ui.Image singleImage = await picture.toImage(singleImageItemWidth.toInt(), singleImageItemHeight.toInt());

    final bytes = await singleImage.toByteData(format: ui.ImageByteFormat.png);
    if (bytes != null) {
      singleImages.add(bytes);
    } else {
      return ;
    }

    
    if (loadImagePosX == colum-1 && loadImagePosY == row) {
      if (!readyCompleter.isCompleted) {
        readyCompleter.complete(true);
      }
      return;
    }
    ++loadImagePosX;
    if (loadImagePosX == colum) {
      loadImagePosX = 0;
      ++loadImagePosY;
    }
 
    loadSingleImage();

  }
}