import 'dart:ui';

import 'package:warx_flutter/layout/hexagon_nodes.mixin.dart';
import 'package:warx_flutter/maingame/basic_game_plugin.dart';
import 'package:warx_flutter/util/completer.safe.extension.dart';

class HexagonMap extends BasicGamePlugin with HexagonNodesMixin {
  bool isInited = false;
  @override
  void initData(Size initSize) {
    if (!isInited) {
      isInited = true;
      super.initData(initSize);

      host.playerA.importantNodes = nodes.values
          .where((element) => element.isPlayerABasicImportant)
          .toList();
      host.playerB.importantNodes = nodes.values
          .where((element) => element.isPlayerBBasicImportant)
          .toList();
      host.onReadyPlayerComplter.safeComplete(true);
    }
  }
}
