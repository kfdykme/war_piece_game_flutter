import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:warx_flutter/layout/hexagon_layout.dart';
import 'package:warx_flutter/maingame/game_controller.dart';
import 'package:warx_flutter/resources/svgloader/svg_color_mapper.dart';
import 'package:warx_flutter/util/game.buildcontext.extension.dart';
import 'package:warx_flutter/util/state.extension.dart';
import 'package:warx_flutter/widgets/game_header.dart';
import 'package:warx_flutter/widgets/game_player_info.dart';

import 'widgets/game_ban_pick.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    Provider.value(value:  GameController(),)
  ], child: const MyApp(),));
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  PictureInfo? pictureInfo;
  @override
  void initState() {
    super.initState();
    vg
        .loadPicture(
            SvgAssetLoader(
              "assets/images/map_base_circle.svg",
            ),
            null)
        .then((value) {
      pictureInfo = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    context.game.setRefresh(() {
      setStateIfMounted();
    });
    return Scaffold(
      body: Stack(
        children: <Widget>[
          HexagonContainer(
              width: size.width,
              height: size.height,
              mapBaseCircleInfo: pictureInfo),
          GameHeader(controller: context.read<GameController>()),
          if (context.game.currentTurn == GameTurn.banpick) GameBanPick(controller: context.read<GameController>())
          else if (context.game.currentTurn == GameTurn.game) GamePlayerInfoContainer()
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
