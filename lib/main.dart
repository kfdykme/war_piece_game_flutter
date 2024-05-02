import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:warx_flutter/layout/hexagon_layout.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/pages/game_controller_base.dart';
import 'package:warx_flutter/pages/player_select_page.dart';
import 'package:warx_flutter/resources/resource_manager.dart';
import 'package:warx_flutter/util/color.random.extension.dart';
import 'package:warx_flutter/util/game.buildcontext.extension.dart';
import 'package:warx_flutter/util/state.extension.dart';
import 'package:warx_flutter/widgets/game_header.dart';
import 'package:warx_flutter/widgets/game_player_info.dart';

import 'widgets/game_ban_pick.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
        useMaterial3: true,
      ),
      home: Row(
        children: [
          Expanded(child:  GameControllerBase(PlayerSelectPage(), 0)),
          Expanded(child:  GameControllerBase(PlayerSelectPage(), 1)),
          
        ],
      ),
    );
  }
}
