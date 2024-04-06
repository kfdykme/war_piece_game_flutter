import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:warx_flutter/resources/resource_manager.dart';

class ChestResourceManager {

  static ChestResourceManager? _i;

  static ChestResourceManager get i => _i ??= ChestResourceManager();

  Map<int,ui.Image> imageCaches = {};
  Map<int,Uint8List> imageBufferCache = {};
  ChestResourceManager() {

  }

  int _row = 8;

  ui.Image? getUiImageByIndex(int index, Function? onLoadFinish) {
    if (imageCaches.containsKey(index)) {
      return imageCaches[index];
    }
    loadImageFromIndex(index).then((value) => onLoadFinish?.call());
    return null;
  }

  Future<ui.Image> loadImageFromIndex(int index) async {
    if (imageBufferCache.containsKey(index)) {
      final buffer = imageBufferCache[index]!;
      await ui.ImmutableBuffer.fromUint8List(buffer).then((value) => ui.instantiateImageCodecFromBuffer(value))
          .then((value) async {
        imageCaches[index] = (await value.getNextFrame()).image;
      });
      return imageCaches[index]!;
    } else {
      chestDataByIndex(index);
      return loadImageFromIndex(index);
    }
  }

  Uint8List chestDataByIndex(int index) {
    if (imageBufferCache.containsKey(index)) {
      return imageBufferCache[index]!;
    }
    int y = index ~/ _row;
    int x = index % _row;
    
    // 8 * 10;
    // final x = Random().nextInt(7) + 1 + (32 - 8);
    // final y = Random().nextInt(9) + 1;   
    y += 1;
    x += 24 + 1;

    final buffer =  ResourceManager.i.getImage(x, y);
    imageBufferCache[index] = buffer;
    loadImageFromIndex(index);
    return buffer;
  }

  
}