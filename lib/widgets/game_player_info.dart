
import 'package:flutter/material.dart';
import 'package:warx_flutter/util/color.random.extension.dart';
import 'package:warx_flutter/util/size.buildcontext.extension.dart';

class GamePlayerInfoContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GamePlayerInfoContainterState();
  }
}

class GamePlayerInfoContainterState extends State<GamePlayerInfoContainer> {
  @override
  Widget build(BuildContext context) {
    final size = context.mSize();
    return Container(width: size.width, height: size.height, child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GamePlayerInfoSingleItem(),
        GamePlayerInfoSingleItem(),
      ],) ,);
  }
}

class GamePlayerInfoSingleItem extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return GamePlayerInfoSingleItemState();
  }
}

class GamePlayerInfoSingleItemState extends State<GamePlayerInfoSingleItem> {
  @override
  Widget build(BuildContext context) {
    final size = context.mSize();
    final width = (size.width - size.height) / 2;
    return Container(color: Color(0).randomColor(), width: width, height: size.height - 100,);
  }
}