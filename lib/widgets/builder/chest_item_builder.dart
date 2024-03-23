
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:warx_flutter/resources/chest_resource_manager.dart';

class ChestItemBuilder {

  
  Widget buildIcon(int index, {
    double size = 100,
    double? border
  }) {
    
    final safeBorder = border ?? size / 5;
    
    return Container(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(safeBorder),
        child: Image.memory(ChestResourceManager.i.chestDataByIndex(index),
      fit: BoxFit.cover, ),
      ),
    
      // child: Image.asset('resources/kenney_1-bit-pack/Tilemap/tileset_legacy.png',
      // fit: BoxFit.none,),
    );
  }
  
  Widget buildIconWithData(Uint8List data, {
    double size = 100,
    double? border
  }) {
    
    final safeBorder = border ?? size / 5;
    
    
    return Container(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(safeBorder),
        child: Image.memory(data,
      fit: BoxFit.cover, ),
      ),
    
      // child: Image.asset('resources/kenney_1-bit-pack/Tilemap/tileset_legacy.png',
      // fit: BoxFit.none,),
    );
  }
}