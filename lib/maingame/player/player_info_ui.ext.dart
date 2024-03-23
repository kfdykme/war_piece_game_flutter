import 'package:warx_flutter/maingame/player/player_info.dart';

mixin PlayerInfoUIExtension {
  
  // UI
  List<Function> updateCallback = [];
  void bindUpdate(Function updateState) {
    updateCallback.add( updateState);
  }

  void notifyRefresh() {
    updateCallback.forEach((element) {element.call();});
  }
}