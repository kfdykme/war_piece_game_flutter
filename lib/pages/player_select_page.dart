import 'package:flutter/material.dart';
import 'package:warx_flutter/maingame/player/player_info.dart';
import 'package:warx_flutter/maingame/player/player_info_logic.ai.mixin.dart';
import 'package:warx_flutter/maingame/player/player_info_network.dart';
import 'package:warx_flutter/pages/main_game_page.dart';
import 'package:warx_flutter/util/game.buildcontext.extension.dart';
import 'package:warx_flutter/util/log.object.extension.dart';
import 'package:warx_flutter/util/state.extension.dart';

class PlayerSelectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PlayerSelectPageState();
  }
}

enum PlayMode { UnSelected, AI, Network }

class PlayerSelectPageState
    extends State<PlayerSelectPage> {
  bool enableA = true;
  bool enableB = true;

  PlayMode mode = PlayMode.UnSelected;

  void checkNeedToStart() {
    if ((!enableA && !enableB) || (mode == PlayMode.AI && (!enableA || !enableB))) {
      context.game.OnAfterPlayerReady();
      if (context.game.nextScene != null) {
        context.game.nextScene?.call( const MainGamePage(title: ""));
      } else {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
          return const MainGamePage(title: "");
        }));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    context.game.networkBase
        .bindOnPlayerJoin((int playerId) {

          try {

            if (playerId == playerAId) {
              enableA = false;
              setStateIfMounted();
            }
            if (playerId == playerBId) {
              enableB = false;
              setStateIfMounted();
            }
          } catch(err) {
            logD("init state error");
          }
      checkNeedToStart();
    });
    context.game.networkBase.JoinGame();
  }

  Widget buildButton(String p, bool enable, Color color) {
    return ElevatedButton(
        style: ButtonStyle(
            foregroundColor:
                MaterialStateProperty.all<Color>(enable
                    ? color
                    : Theme.of(context).disabledColor),
            overlayColor:
                MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (!enable) {
                  return null;
                }
                if (states
                    .contains(MaterialState.hovered)) {
                  return Theme.of(context)
                      .primaryColor
                      .withOpacity(0.04);
                }
                if (states
                        .contains(MaterialState.focused) ||
                    states
                        .contains(MaterialState.pressed)) {
                  return Theme.of(context)
                      .primaryColor
                      .withOpacity(0.12);
                }
                return null; // Defer to the widget's default.
              },
            ),
            backgroundColor:
                MaterialStateProperty.resolveWith<Color?>(
                    (states) {
              if (!enable) {
                return null;
              }
              return null;
            })),
        onPressed: () {
          if (enable) {
            onSelectPlayer(p);
          } else {}
        },
        child: Text(enable ? '我是玩家${p}' : '玩家${p} 正在等待中'));
  }

  // Widget buildModeCheckbox()

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [  
        TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith(
                          (states) {
                    //设置按下时的背景颜色
                    if (states
                        .contains(MaterialState.pressed)) {
                      return const Color.fromARGB(
                          255, 150, 236, 215);
                    }
                    if (mode == PlayMode.AI) {
                      return const Color.fromARGB(
                          255, 150, 236, 215);
                    }
                    //默认不使用背景颜色
                    return null;
                  }),
                ),
                onPressed: () { 
                },
                child: Text("Game: ${context.game.hashCode.toString()}-${widget.hashCode}-${hashCode}")),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith(
                          (states) {
                    //设置按下时的背景颜色
                    if (states
                        .contains(MaterialState.pressed)) {
                      return const Color.fromARGB(
                          255, 150, 236, 215);
                    }
                    if (mode == PlayMode.AI) {
                      return const Color.fromARGB(
                          255, 150, 236, 215);
                    }
                    //默认不使用背景颜色
                    return null;
                  }),
                ),
                onPressed: () {
                  mode = PlayMode.AI;
                  setStateIfMounted();
                },
                child: const Text("VS COM")),
            TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith(
                          (states) {
                    //设置按下时的背景颜色
                    if (states
                        .contains(MaterialState.pressed)) {
                      return const Color.fromARGB(
                          255, 150, 236, 215);
                    }
                    if (mode == PlayMode.Network) {
                      return const Color.fromARGB(
                          255, 150, 236, 215);
                    }
                    //默认不使用背景颜色
                    return null;
                  }),
                ),
                onPressed: () {
                  mode = PlayMode.Network;
                  setStateIfMounted();
                },
                child: const Text("VS Network"))
          ],
        ),
        const SizedBox(height: 30),
        buildButton(
            'A',
            enableA && mode != PlayMode.UnSelected,
            Theme.of(context).primaryColorDark),
        const SizedBox(height: 30),
        buildButton(
            'B',
            enableB && mode != PlayMode.UnSelected,
            Theme.of(context).primaryColorLight)
      ],
    ));
  } 
  void onSelectPlayer(String p) {
    if (p == 'A') {
      context.game.playerB = mode == PlayMode.Network
          ? PlayerInfoNetwork(playerBId)
          : PlayerInfoAi(playerBId);

      context.game.localPlayer = context.game.playerA;
      enableA = false;
    } else if (p == 'B') {
      context.game.playerA = mode == PlayMode.Network
          ? PlayerInfoNetwork(playerAId)
          : PlayerInfoAi(playerAId);

      context.game.localPlayer = context.game.playerB; 
      enableB = false;
    }
    // context.game.playerA.color = Theme.of(context).primaryColorDark;
    // context.game.playerB.color = Theme.of(context).primaryColorLight;

    context.game.networkBase
        .JoinPlayer(context.game.localPlayer!.id);
    checkNeedToStart();
    // PlayerInfo.playerA.fillPieces([0, 1, 2, 3]);
    // PlayerInfo.playerB.fillPieces([4, 5, 6, 7]);
    // PlayerInfo.playerA.bindNotifyUI(PlayerInfo.playerA.notifyRefresh);
    // PlayerInfo.playerB.bindNotifyUI(PlayerInfo.playerB.notifyRefresh);

    // context.game.currentPlayer = null;
    // context.game.nextPlayer();
  }
}
