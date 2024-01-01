
import 'dart:typed_data';

import 'package:warx_flutter/resources/resource_manager.dart';

class ChestResourceManager {

  static ChestResourceManager? _i;

  static ChestResourceManager get i => _i ??= ChestResourceManager();

  ChestResourceManager() {

  }

  int _row = 8;

  Uint8List chestDataByIndex(int index) {
    int y = index ~/ _row;
    int x = index % _row;
    
    // 8 * 10;
    // final x = Random().nextInt(7) + 1 + (32 - 8);
    // final y = Random().nextInt(9) + 1;   
    y += 1;
    x += 24 + 1;
    
    return ResourceManager.i.getImage(x, y);
  }
}