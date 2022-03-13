import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/screens/menu/menu_screen.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/services/match_service.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/text_styles.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/judge_card.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:dojo_app/widgets/widget_collection_title.dart';
import 'package:page_transition/page_transition.dart';
import 'judge_list_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;

//ignore: must_be_immutable
class JudgeListScreen extends StatefulWidget {
  JudgeListScreen() {
    // Constructor
  }

  @override
  _JudgeListScreenState createState() => _JudgeListScreenState();
}

class _JudgeListScreenState extends State<JudgeListScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  late String nickname;
  late String userID = globals.dojoUser.uid;

  // Initialize services required
  DatabaseServices databaseServices = DatabaseServices();
  MatchService matchService = MatchService();

  /// Declare variable where most of the logic is managed for this screen
  // majority of the logic is in this object
  late JudgeListBloc judgeListController;

  /// StreamController to manage loading required data before moving forward
  // to load level selection page
  final _judgeListWrapperController = StreamController<Map>();
  Stream<Map> get judgeListWrapperStream => _judgeListWrapperController.stream;
  Sink<Map> get judgeListWrapperSink => _judgeListWrapperController.sink;

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  void dispose() {
    printBig('Judge List Dispose Called', 'true');
    super.dispose();
  }

  void setup() async {
    /// *******************************************
    /// Preload required data before loading screen or bloc
    /// ********************************************

    /// Instantiate controller for this Game Mode page
    judgeListController = JudgeListBloc(userID: userID);
    await judgeListController.preloadScreenSetup();
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
        stream: judgeListController.judgeListWrapperStream,
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
                            height: (MediaQuery.of(context).size.height) + 100,
                                /*(MediaQuery.of(context).padding).top -
                                (MediaQuery.of(context).padding).bottom,*/
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
                                          headLine: 'Judging',
                                          bodyText:
                                          'Watch games and verify to earn rewards.'),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text('DOJO TOKENS EARNED', style: Theme.of(context).textTheme.caption)
                                              ]
                                            ),
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 16,
                                                  backgroundImage: AssetImage('images/dojo-token.png'),
                                                ),
                                                SizedBox(width:8),
                                                BodyText5Bold(text: '1300'),
                                              ]
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      WidgetCollectionTitle(title: 'Games open for judging'),
                                      StreamBuilder<List>(
                                        stream: judgeListController.matchesOpenForJudgingStream,
                                        builder: (context, snapshot) {
                                          if (snapshot.data != null) {
                                            final listOfMatchesOpenForJudging = snapshot.data as List;
                                            return SizedBox(
                                              height: 95,
                                              child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: listOfMatchesOpenForJudging.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    String playerOneUserID = listOfMatchesOpenForJudging[index]['players'][0];
                                                    return JudgeCard(
                                                      avatarImage: 'images/avatar-blank.png',
                                                      avatarFirstLetter: 'M',
                                                      title:
                                                      '${listOfMatchesOpenForJudging[index]['playerNicknames'][playerOneUserID]}',
                                                      gameID: '${listOfMatchesOpenForJudging[index]['gameID']}',
                                                      playerOneNickname:
                                                      '${listOfMatchesOpenForJudging[index]['playerNicknames'][playerOneUserID]}',
                                                      playerOneScore:
                                                      '${listOfMatchesOpenForJudging[index]['playerScores'][playerOneUserID]}',
                                                      playerOneVideo:
                                                      '${listOfMatchesOpenForJudging[index]['playerVideos'][playerOneUserID]}',
                                                      playerOneUserID: playerOneUserID,
                                                      judgeRequestID: '${listOfMatchesOpenForJudging[index]['id']}',
                                                      dateUpdated: '${listOfMatchesOpenForJudging[index]['dateUpdated']}',
                                                      gameTitle: '${listOfMatchesOpenForJudging[index]['gameTitle']}',
                                                    );
                                                  }),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      ),
                                      WidgetCollectionTitle(title: 'Games pending consensus'),
                                      StreamBuilder<List>(
                                        stream: judgeListController.matchesPendingConsensusStream,
                                        builder: (context, snapshot) {
                                          if (snapshot.data != null) {
                                            final listOfMatchesPendingConsensus = snapshot.data as List;
                                            return SizedBox(
                                              height: 95,
                                              child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: listOfMatchesPendingConsensus.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    String playerOneUserID = listOfMatchesPendingConsensus[index]['players'][0];
                                                    return JudgeCard(
                                                      avatarImage: 'images/avatar-blank.png',
                                                      avatarFirstLetter: 'M',
                                                      title:
                                                      '${listOfMatchesPendingConsensus[index]['playerNicknames'][playerOneUserID]}',
                                                      gameID: '${listOfMatchesPendingConsensus[index]['gameID']}',
                                                      playerOneNickname:
                                                      '${listOfMatchesPendingConsensus[index]['playerNicknames'][playerOneUserID]}',
                                                      playerOneScore:
                                                      '${listOfMatchesPendingConsensus[index]['playerScores'][playerOneUserID]}',
                                                      playerOneVideo:
                                                      '${listOfMatchesPendingConsensus[index]['playerVideos'][playerOneUserID]}',
                                                      playerOneUserID: playerOneUserID,
                                                      judgeRequestID: '${listOfMatchesPendingConsensus[index]['id']}',
                                                      dateUpdated: '${listOfMatchesPendingConsensus[index]['dateUpdated']}',
                                                      cardType: 'pending',
                                                      gameTitle: '${listOfMatchesPendingConsensus[index]['gameTitle']}',
                                                    );
                                                  }),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      ),
                                      WidgetCollectionTitle(title: 'You Successfully Judged'),
                                      StreamBuilder<List>(
                                        stream: judgeListController.matchesClosedSuccessJudgementStream,
                                        builder: (context, snapshot) {
                                          if (snapshot.data != null) {
                                            final listOfMatchesSuccessJudgement = snapshot.data as List;
                                            return SizedBox(
                                              height: 95,
                                              child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: listOfMatchesSuccessJudgement.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    String playerOneUserID = listOfMatchesSuccessJudgement[index]['players'][0];
                                                    return JudgeCard(
                                                      avatarImage: 'images/avatar-blank.png',
                                                      avatarFirstLetter: 'M',
                                                      title:
                                                      '${listOfMatchesSuccessJudgement[index]['playerNicknames'][playerOneUserID]}',
                                                      gameID: '${listOfMatchesSuccessJudgement[index]['gameID']}',
                                                      playerOneNickname:
                                                      '${listOfMatchesSuccessJudgement[index]['playerNicknames'][playerOneUserID]}',
                                                      playerOneScore:
                                                      '${listOfMatchesSuccessJudgement[index]['playerScores'][playerOneUserID]}',
                                                      playerOneVideo:
                                                      '${listOfMatchesSuccessJudgement[index]['playerVideos'][playerOneUserID]}',
                                                      playerOneUserID: playerOneUserID,
                                                      judgeRequestID: '${listOfMatchesSuccessJudgement[index]['id']}',
                                                      dateUpdated: '${listOfMatchesSuccessJudgement[index]['dateUpdated']}',
                                                      cardType: 'success',
                                                      gameTitle: '${listOfMatchesSuccessJudgement[index]['gameTitle']}',
                                                    );
                                                  }),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      ),
                                      WidgetCollectionTitle(title: 'You Failed in Judgement'),
                                      StreamBuilder<List>(
                                        stream: judgeListController.matchesClosedFailedJudgementStream,
                                        builder: (context, snapshot) {
                                          if (snapshot.data != null) {
                                            final listOfMatchesFailedJudgement = snapshot.data as List;
                                            return SizedBox(
                                              height: 95,
                                              child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: listOfMatchesFailedJudgement.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    String playerOneUserID = listOfMatchesFailedJudgement[index]['players'][0];
                                                    return JudgeCard(
                                                      avatarImage: 'images/avatar-blank.png',
                                                      avatarFirstLetter: 'M',
                                                      title:
                                                      '${listOfMatchesFailedJudgement[index]['playerNicknames'][playerOneUserID]}',
                                                      gameID: '${listOfMatchesFailedJudgement[index]['gameID']}',
                                                      playerOneNickname:
                                                      '${listOfMatchesFailedJudgement[index]['playerNicknames'][playerOneUserID]}',
                                                      playerOneScore:
                                                      '${listOfMatchesFailedJudgement[index]['playerScores'][playerOneUserID]}',
                                                      playerOneVideo:
                                                      '${listOfMatchesFailedJudgement[index]['playerVideos'][playerOneUserID]}',
                                                      playerOneUserID: playerOneUserID,
                                                      judgeRequestID: '${listOfMatchesFailedJudgement[index]['id']}',
                                                      dateUpdated: '${listOfMatchesFailedJudgement[index]['dateUpdated']}',
                                                      cardType: 'fail',
                                                      gameTitle: '${listOfMatchesFailedJudgement[index]['gameTitle']}',
                                                    );
                                                  }),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      ),
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
