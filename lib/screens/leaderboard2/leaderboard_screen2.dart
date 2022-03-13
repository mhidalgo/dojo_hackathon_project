import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/screens/menu/menu_screen.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/services/match_service.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/judge_card.dart';
import 'package:dojo_app/widgets/leaderboard.dart';
import 'package:dojo_app/widgets/leaderboard_your_score.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:dojo_app/widgets/widget_collection_title.dart';
import 'package:page_transition/page_transition.dart';
import 'leaderboard2_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;

//ignore: must_be_immutable
class Leaderboard2Screen extends StatefulWidget {
  Leaderboard2Screen({required this.gameRulesID, required this.userID}) {
    // Constructor
  }

  String gameRulesID;
  String userID;

  @override
  _Leaderboard2ScreenState createState() => _Leaderboard2ScreenState();
}

class _Leaderboard2ScreenState extends State<Leaderboard2Screen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  late String nickname;
  late String userID = globals.dojoUser.uid;

  /// Manage state of player so this leaderboard knows what to load
  // labeled as "leaderboardStatus" on the leaderboard collection
  // the state is based on the leaderboard 'status' field
  // options are: pending (no judge consensus yet), confirmed (judge consensus met), winner (a winner has been picked)
  // in method setup(), this is set to the correct state base on the player's leaderboard "status"
  late String playerState = 'pending'; // default

  // Initialize services required
  DatabaseServices databaseServices = DatabaseServices();
  MatchService matchService = MatchService();

  /// Declare variable where most of the logic is managed for this screen
  // majority of the logic is in this object
  late Leaderboard2Bloc leaderboardController;

  /// StreamController to manage loading required data before moving forward
  // to load level selection page
  final _leaderboardWrapperController = StreamController<Map>();
  Stream<Map> get leaderboardWrapperStream => _leaderboardWrapperController.stream;
  Sink<Map> get leaderboardWrapperSink => _leaderboardWrapperController.sink;

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  void dispose() {
    _leaderboardWrapperController.close();
    super.dispose();
  }

  void setup() async {
    /// *******************************************
    /// Preload required data before loading screen or bloc
    /// ********************************************

    /// Instantiate controller for this Game Mode page
    leaderboardController = Leaderboard2Bloc(userID: userID, gameRulesID: widget.gameRulesID);
    await leaderboardController.preloadScreenSetup();

    // get the player state so this screen can show the correct data
    // options: 'pending', 'confirmed', 'winner', 'loser'
    playerState = leaderboardController.userLeaderboardData['leaderboardStatus'];

    // testing
    printBig('Leaderboard ID', '${leaderboardController.userLeaderboardData['id']}');
    printBig('Game ID', '${leaderboardController.userLeaderboardData['gameID']}');
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

  /// ***********************************************************************
  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map>(
        stream: leaderboardController.leaderboardWrapperStream,
        initialData: {
          'ready': false,
        },
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final ready = snapshot.data!['ready'] as bool;
            if (ready == true) {
              return Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: primarySolidBackgroundColor,
                appBar: AppBar(
                  title: PageTitle(title: 'DOJO LEADERBOARD'),
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
                            height: (MediaQuery.of(context).size.height),
                            child: Stack(
                              children: <Widget>[
                                Opacity(opacity: 0.25, child: BackgroundTopImage(imageURL: 'images/castle.jpg')),
                                Container(
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 16,
                                      ),
                                      HostCard(
                                          headLine: '${leaderboardController.getGameRulesTitle}?',
                                          bodyText:
                                          'Who is the master?'),
                                      SizedBox(height: 16),
                                      LeaderboardYourScore(score: leaderboardController.userLeaderboardData['score'], playerLeaderboardStatus: playerState,),
                                      SizedBox(height:16),
                                      Leaderboard(score: 10, rank: 1, playerNickname: 'Vanielson', leaderboardController: leaderboardController),
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

            } else {
              return Stack(
                  children: [
                  LoadingScreen(displayVisual: 'loading icon'),
                  BackgroundOpacity(opacity: 'medium'),
                  ],
              );
            }
          } else {
            return Stack(
              children: [
                LoadingScreen(displayVisual: 'loading icon'),
                BackgroundOpacity(opacity: 'medium'),
              ],
            );
          }
        });
    // top module
  }
}
