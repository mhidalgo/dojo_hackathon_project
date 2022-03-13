import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/screens/game_modes/game_modes_screen.dart';
import 'package:dojo_app/services/create_game_service.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/services/copy_levels_service.dart';
import 'package:dojo_app/services/database.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/services/match_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dojo_app/services/local_notification_service.dart';
import 'dart:math';

/// The purpose of GamesWrapper
// The class will obtain data that the level page requires
// while the class fetches the data, a loading screen will be displayed to the user
// once all required data is completed
// the stream in the widget is updated with this data
// which informs the app to move forward

class GameModesWrapper extends StatefulWidget {
  GameModesWrapper() {
    //
  }

  /// determine the type of match we're dealing with
  // pulls from global file because there aren't any other categories or match types yet
  // so it is currently hard coded in globals
  final String category = globals.category;
  final String levelGroupID = globals.levelGroupID;
  final String matchGroupID = globals.matchGroupID;
  final List gameModes = globals.fitnessGameModesList;

  // Obtain this user's UID
  final String userID = globals.dojoUser.uid;

  @override
  _GameModesWrapperState createState() => _GameModesWrapperState();
}

class _GameModesWrapperState extends State<GameModesWrapper> {
  /// ***********************************************************************
  /// Setup variables
  /// ***********************************************************************

  // Setup variables for passed in data
  late String userID = widget.userID;
  late String levelGroupID = widget.levelGroupID;
  late String matchGroupID = widget.matchGroupID;
  late List gameModeList =
      widget.gameModes; // not used yet, but should migrate to using this so that gameMode screen knows which active gameModes and groupIDs to display

  // Setup getting nickname
  late var databaseService = DatabaseService(uid: userID);
  late String nickname;

  // Initialize services required
  DatabaseServices databaseServices = DatabaseServices();
  MatchService matchService = MatchService();

  // Setup getting initial background video to play on levels
  VideoDatabaseService videoDatabaseServices = VideoDatabaseService();
  late String gameModeBackgroundVideoURL;

  // Setup variable to help us determine if all levels are completed
  // so that we can handle UI cases when the user reaches this state
  bool allLevelsCompleted = false;

  // Setup player records
  String winLossTieRecord = '0W-0L-0T';

  late Map<String, dynamic> gameModesWrapperMap;

  /// StreamController to manage loading required data before moving forward
  // to load level selection page
  final _gameModesWrapperController = StreamController<Map>();
  Stream<Map> get gameModesWrapperStream => _gameModesWrapperController.stream;
  Sink<Map> get gameModesWrapperSink => _gameModesWrapperController.sink;

  /// ***********************************************************************
  /// Initialization methods
  /// ***********************************************************************

  @override
  void initState() {
    super.initState();

    /// Run method to refresh user token and if new save to DB.
    videoDatabaseServices.generateUserToken();

    /// Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(videoDatabaseServices.saveTokenToDatabase);
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);
    LocalNotificationService.initialize(context);

    /// Handles App notification when app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final routeFromMessage = message.data["route"];
      }
    });

    // Foreground listening
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        print(message.notification!.body);
        print(message.notification!.title);
      }

      LocalNotificationService.display(message);
    });

    /// Message received while app is background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final routeFromMessage = message.data["route"];
      // Navigator.of(context).pushNamed(routeFromMessage);
    });

    /// Primary method acting as the hub
    setupLevelSelection();
  }

  @override
  void dispose() {
    _gameModesWrapperController.close();
    super.dispose();
  }

  /// ***********************************************************************
  /// Primary function
  /// ***********************************************************************

  void setupLevelSelection() async {
    /// get nickname
    nickname = await getNickname(userID);
    setGlobalNickname(nickname); // store in global variable for everywhere access

    /// Set game rules ID
    // currently, Dojo only has 1 game so there is only 1 game rule
    String gameRulesID = 'ZlYBWj4jbLddLJEDZbLK';
    String gameRulesIDBasketballFoulShots = 'CgMUKHApCyuikuwm2L30';
    String gameRulesIDPushupSprint = 'DLdsgABrmYpoLWw2x2C0';
    String gameMode = 'king of the hill';
    String basketballRoute;
    String pushupRoute;

    /// Service manages creating new games of varying types
    CreateGameService createGameService = CreateGameService();

    /// get basketball match info
    Map matchDetailsBasketball = await databaseServices.fetchLatestStartingGameDetails2(userID: userID, gameRulesID: gameRulesIDBasketballFoulShots);

    /// get pushup match info
    Map matchDetailsPushupSprint = await databaseServices.fetchLatestStartingGameDetails2(userID: userID, gameRulesID: gameRulesIDPushupSprint);

    /// Where should Basketball card route to?
    // if user has not paid (t/f method), and no match exists (gameRulesID, groupID?) --> pay to play (gameRulesID) --> create game --> game xp
    // - find match from matchesAll where gameRulesID = 'basketball foul shot make'
    // -- if no match exists, then create it and set paid to false
    if (matchDetailsBasketball.isEmpty) {
      // create the game
      await createGameService.createKingOfTheHillGame(gameMode: gameMode, gameRulesID: gameRulesIDBasketballFoulShots);
    }

    if (matchDetailsPushupSprint.isEmpty) {
      // create the game
      await createGameService.createKingOfTheHillGame(gameMode: gameMode, gameRulesID: gameRulesIDPushupSprint);
    }

    // on game screen, tapping on basketball card sends the user where?
    // options: payment screen, play screen, leaderboard
    if (matchDetailsBasketball['paymentReceived'] == false && matchDetailsBasketball['playerScores'].isEmpty) {
      // the player has not paid yet, so they haven't played either
      basketballRoute = 'insert tokens screen';
    } else if (matchDetailsBasketball['paymentReceived'] == true && matchDetailsBasketball['playerScores'].isEmpty) {
      // the player has paid but has not played
      basketballRoute = 'game screen';
    } else if (matchDetailsBasketball['paymentReceived'] == true && matchDetailsBasketball['playerScores'].isNotEmpty) {
      // the player has paid and has played
      basketballRoute = 'leaderboard screen';
    } else {
      // default
      basketballRoute = 'pay screen';
    }

    // on game screen, tapping on basketball card sends the user where?
    // options: payment screen, play screen, leaderboard
    if (matchDetailsPushupSprint['paymentReceived'] == false && matchDetailsPushupSprint['playerScores'].isEmpty) {
      // the player has not paid yet, so they haven't played either
      pushupRoute = 'pay screen';
    } else if (matchDetailsPushupSprint['paymentReceived'] == true && matchDetailsPushupSprint['playerScores'].isEmpty) {
      // the player has paid but has not played
      pushupRoute = 'game screen';
    } else if (matchDetailsPushupSprint['paymentReceived'] == true && matchDetailsPushupSprint['playerScores'].isNotEmpty) {
      // the player has paid and has played
      pushupRoute = 'leaderboard screen';
    } else {
      // default
      pushupRoute = 'pay screen';
    }

    /// Get notifications for match
    // List<Widget> notificationWidgetList = getNotifications(matchDetails);

    /// get default video background that should play on initial load of game mode page
    gameModeBackgroundVideoURL = await getGameModeBackgroundVideoURL();

    /// Determine if they beat all the levels
    // so we can handle that case when level_select.dart loads
    // allLevelsCompleted = await databaseServices.hasUserCompletedAllLevels(levelGroupID: levelGroupID, userID: userID);

    /// get this user's pushup count over time, personal record, and win/loss/record
    // winLossTieRecord = await getWinLossTieRecord(matchDetails, userID, gameRulesID);

    /// Create map data to send to stream
    // currently, we do not use the Map's nickname or videoURL fields
    // TODO: later, consider storing values in widget tree and passing via GetX, or provider so we can
    // avoid using global variables
    gameModesWrapperMap = {
      'ready': true,
      'backgroundVideo': gameModeBackgroundVideoURL,
      'nickname': nickname,
      'userID': userID,
      'gameModes': gameModeList,
      'basketballRoute': basketballRoute,
      'pushupRoute': pushupRoute,
      'gameRulesIDBasketballFoulShots': gameRulesIDBasketballFoulShots,
      'gameRulesIDPushupSprint': gameRulesIDPushupSprint,
      'gameMapBasketballFoulShots': matchDetailsBasketball,
      'gameMapPushupSprint': matchDetailsPushupSprint,
      'gameIDBasketballFoulShots': matchDetailsBasketball['id'],
      'gameIDPushupSprint': matchDetailsPushupSprint['id'],

    };

    /// set global data that levels page will use
    // TODO remove usage of global data, instead use getX for state management
    await setGlobalWrapperMap('gameModes', gameModesWrapperMap);

    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // app moves forward
    gameModesWrapperSink.add(gameModesWrapperMap);
  }

  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************

  Future<String> getNickname(userID) async {
    // get default background video to play on level selection
    return await databaseServices.fetchNickname(userID: userID);
  }

  Future<void> checkMatchStateAndExpire(matchGroupID, userID) async {
    // QuerySnapshot matchDetails = await databaseServices.fetchLatestSingleGameDetails('matches', matchGroupID, userID);
    QuerySnapshot matchDetails = await databaseServices.fetchLatestStartingGameDetails('matches', matchGroupID, userID);

    if (matchDetails.docs.isNotEmpty) {
      /// Get match state
      String matchStatus = matchService.getPlayersStatusInAMatch(matchDetails);

      /// Check whether match has expired
      bool expireMatch = matchService.isMatchExpired(matchDetails);

      /// update match so both or one player forfeits
      if (expireMatch == true) {
        await matchService.forfeitMatch(matchDetails, matchStatus, userID);
      }
    }
  }

  List<Widget> getNotifications(QuerySnapshot matchDetails) {
    List<Widget> notificationWidgetList = [Container()];

    if (matchDetails.docs.isNotEmpty) {
      MatchService matchService = MatchService();
      notificationWidgetList = matchService.getMatchNotifications(matchDetails);
    }
    return notificationWidgetList;
  }

  Future<String> getGameModeBackgroundVideoURL() async {
    // obtain gameMode details, which contains the a video URL
    Map gameModeDetailsMap = await databaseServices.fetchGameModeDetails();

    // instantiate random number class
    Random random = Random();

    // generate random number based on length of background videos array
    int randomNumber = random.nextInt(gameModeDetailsMap['backgroundVideos'].length);

    // set background video to play on game modes screen
    String defaultVideo = gameModeDetailsMap['backgroundVideos'][randomNumber];

    return defaultVideo;
  }

  Future<void> copyLevels(userID, levelGroupID, nicknameX) async {
    /// Check if the user has initial levels added for this specific level group
    // if user does not have levels, this will add them so they show up on the level selection screen
    CopyLevelService levelObject = CopyLevelService(levelGroupID: levelGroupID, userID: userID, nickname: nicknameX);
    await levelObject.addInitialLevelsWhenUserHasNone();
  }

  Future<String> getWinLossTieRecord(QuerySnapshot matchDetails, userID, gameRulesID) async {
    String winLossTieRecord = '0W-0L-0T';

    //if (matchDetails.docs.isNotEmpty) {
      /// Store as a map and obtain data
      //var details = matchDetails.docs.first.data() as Map<dynamic, dynamic>;

      Map playerOneRecords = await matchService.getPlayerRecords(gameRulesID, userID);

      if (playerOneRecords['winLossTieRecord'] != null) {
        winLossTieRecord = playerOneRecords['winLossTieRecord'];
      }
    //}

    return winLossTieRecord;
  }

  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map>(
        stream: gameModesWrapperStream,
        initialData: {
          'ready': false,
        },
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final ready = snapshot.data!['ready'] as bool;
            if (ready == true) {
              return GameModesScreen(gameModeWrapperMap: gameModesWrapperMap);
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
  }
}
