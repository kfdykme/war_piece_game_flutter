

import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:warx_flutter/util/color.random.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';

class SvgColorMapper extends ColorMapper{
  @override
  Color substitute(String? id, String elementName, String attributeName, Color color) {
    logD("substitute id $id, elementName $elementName, attributeName $attributeName, color $color");
    return Color(0).randomColor();
  }
  
}