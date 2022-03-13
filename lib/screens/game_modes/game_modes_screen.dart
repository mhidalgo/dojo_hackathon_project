import 'package:dojo_app/screens/game/game_screen_wrapper.dart';
import 'package:dojo_app/screens/insert_tokens/insert_token_wrapper.dart';
import 'package:dojo_app/screens/leaderboard2/leaderboard_screen2.dart';
import 'package:dojo_app/screens/levels/levels_wrapper.dart';
import 'package:dojo_app/screens/matches_A2P/matches_wrapper.dart';
import 'package:dojo_app/screens/menu/menu_screen.dart';
import 'package:dojo_app/screens/video_player/video_full_screen.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/game_mode_card.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'game_modes_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  //print(message.notification!.title);
}

//ignore: must_be_immutable
class GameModesScreen extends StatefulWidget {
  GameModesScreen({required this.gameModeWrapperMap}) {
    // Constructor
  }

  final Map gameModeWrapperMap;

  @override
  _GameModesScreenState createState() => _GameModesScreenState();
}

class _GameModesScreenState extends State<GameModesScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  /// Unpack passed in parameters
  // the global values are set in the levels_wrapper
  late String defaultBackgroundVideo = widget.gameModeWrapperMap['backgroundVideo'];
  late String nickname = widget.gameModeWrapperMap['nickname'];
  late String userID = widget.gameModeWrapperMap['userID'];
  late String pushupRoute = widget.gameModeWrapperMap['pushupRoute'];
  late String basketballRoute = widget.gameModeWrapperMap['basketballRoute'];
  late String gameRulesIDPushupSprint = widget.gameModeWrapperMap['gameRulesIDPushupSprint'];
  late String gameRulesIDBasketballFoulShots = widget.gameModeWrapperMap['gameRulesIDBasketballFoulShots'];
  late Map gameMapBasketballFoulShots = widget.gameModeWrapperMap['gameMapBasketballFoulShots'];
  late Map gameMapPushupSprint = widget.gameModeWrapperMap['gameMapPushupSprint'];

  /// Declare variable where mot of the logic is managed for this page
  // majority of the logic is in this object
  late GameModesBloc gameModesController;

  /// Manage opacity of layer on top of background video
  String videoOpacity = 'medium';

  @override
  void initState() {
    super.initState();

    /// Instantiate controller for this Game Mode page
    gameModesController = GameModesBloc(userID: userID);
  }

  @override
  void dispose() {
    printBig('Game Modes Dispose Called', 'true');
    super.dispose();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  backButtonAction() {
    print('do nothing');
  }

  menuAction() {
    Navigator.push(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: Menu()));
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  setup() {
    //
  }

  Widget determinePushupRoute(){
    if (pushupRoute == 'insert tokens screen') {
      return InsertTokenWrapper(gameRulesID: gameRulesIDPushupSprint, userID: userID, gameMap: gameMapPushupSprint);
    } else if (pushupRoute == 'game screen') {
      return GameScreenWrapper(userID: userID, gameMode: gameMapPushupSprint['gameMode'], gameMap: gameMapPushupSprint, groupID: 'xyz', id: gameMapPushupSprint['id']);
    } else if (pushupRoute == 'leaderboard screen') {
      return Leaderboard2Screen(gameRulesID: gameRulesIDPushupSprint, userID: userID);
    }

    return InsertTokenWrapper(gameRulesID: gameRulesIDPushupSprint, userID: userID, gameMap: gameMapPushupSprint);
  }

  determineBasketballRoute() {
    if (basketballRoute == 'insert tokens screen') {
      return InsertTokenWrapper(gameRulesID: gameRulesIDBasketballFoulShots, userID: userID, gameMap: gameMapBasketballFoulShots);
    } else if (basketballRoute == 'game screen') {
      return GameScreenWrapper(userID: userID, gameMode: gameMapBasketballFoulShots['gameMode'], gameMap: gameMapBasketballFoulShots, groupID: 'xyz', id: gameMapBasketballFoulShots['id']);
    } else if (basketballRoute == 'leaderboard screen') {
      // return GameScreenWrapper(userID: userID, gameMode: gameMapBasketballFoulShots['gameMode'], gameMap: gameMapBasketballFoulShots, groupID: 'xyz', id: gameMapBasketballFoulShots['id']);
      return Leaderboard2Screen(gameRulesID: gameRulesIDBasketballFoulShots, userID: userID);
    }

    return InsertTokenWrapper(gameRulesID: gameRulesIDBasketballFoulShots, userID: userID, gameMap: gameMapBasketballFoulShots);
  }
  /// ***********************************************************************
  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primarySolidBackgroundColor,
      appBar: AppBar(
        title: PageTitle(title: 'DOJO'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            print('tap');
            menuAction();
          },
        ),
        backgroundColor: primarySolidBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(0),
            child: Column(
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width),
                  height: (MediaQuery.of(context).size.height) - (MediaQuery.of(context).padding).top - (MediaQuery.of(context).padding).bottom,
                  child: Stack(
                    children: <Widget>[
                      VideoFullScreen(key: UniqueKey(), videoURL: defaultBackgroundVideo, videoConfiguration: 3),
                      BackgroundOpacity(opacity: videoOpacity),
                      Container(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 16,
                            ),
                            HostCard(headLine: 'Welcome $nickname', bodyText: 'Test your athletic capability vs the world.'),
                            SizedBox(height: 16),
                            GameModeCard(
                                onPressAction: () {
                                  Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: determinePushupRoute()),
                                      (Route<dynamic> route) => false);
                                },
                                subtitleIcon: FontAwesomeIcons.universalAccess,
                                subtitle: 'King of the Hill',
                                title: 'Pushups',
                                description: 'Max pushups in 60 seconds'),
                            SizedBox(height: 16),
                            Divider(height: 1.0, thickness: 1.0, indent: 16.0, endIndent: 16.0),
                            SizedBox(height: 16),
                            SizedBox(height: 8),
                            GameModeCard(
                              onPressAction: () {
                                Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: determineBasketballRoute()),
                                    (Route<dynamic> route) => false);
                              },
                              subtitleIcon: FontAwesomeIcons.universalAccess,
                              subtitle: 'King of the Hill',
                              title: 'Basketball Foul Shots',
                              description: 'Max foul shot makes in 60 seconds',
                              icon2x: false,
                              displayWinLossTieRecord: true,
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // top module
  }
}
