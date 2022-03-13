import 'dart:async';
import 'package:dojo_app/screens/game/game_screen.dart';
import 'package:dojo_app/services/match_service.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:flutter/material.dart';

/// The purpose of GamesWrapper
// The class will obtain data that the game_screen page requires
// while the class fetches the data, a loading screen will be displayed to the user
// once all required data is fetched
// the stream in the widget is updated with this data
// which informs the app to move forward

class GameScreenWrapper extends StatefulWidget {
  GameScreenWrapper({
    required this.userID,
  required this.gameMode,
  required this.groupID,
  required this.id,
  required this.gameMap}) {
    //
  }

  // Contains required data for game screen
  // this comes from the previous page, level_selection or matches
  final dynamic userID;
  final String gameMode;
  final String groupID;
  final String id;
  final Map gameMap;

  @override
  _GameScreenWrapperState createState() => _GameScreenWrapperState();
}

class _GameScreenWrapperState extends State<GameScreenWrapper> {
  /// ***********************************************************************
  /// Setup variables
  /// ***********************************************************************

  // Setup variables for passed in data
  late String userID = widget.userID;
  late String gameMode = widget.gameMode;
  late String groupID = widget.groupID;
  late String id = widget.id;
  late Map gameMap = widget.gameMap; // contains every field in a level/match doc

  // Manages whether an opponent video is displayed or not
  DatabaseServices databaseServices = DatabaseServices();
  late String videoURL;
  bool opponentVideoAvailable = false;

  /// StreamController to manage loading required data before moving forward
  // to load game screen page
  final _gameScreenWrapperController = StreamController<Map>();
  Stream<Map> get gameScreenWrapperStream => _gameScreenWrapperController.stream;
  Sink<Map> get gameScreenWrapperSink => _gameScreenWrapperController.sink;

  /// ***********************************************************************
  /// Initialization methods
  /// ***********************************************************************

  @override
  void initState() {
    super.initState();

    /// Primary method acting as the hub
    setupGameScreen();
  }

  @override
  void dispose () {
    _gameScreenWrapperController.close();
    super.dispose();
  }

  /// ***********************************************************************
  /// Primary function
  /// ***********************************************************************

  void setupGameScreen() async {
    videoURL = '';
    opponentVideoAvailable = false;

    /// Get this player's personal records like win/loss, personal best, and scores over time
    MatchService matchService = MatchService();
    Map playerOneRecords = await matchService.getPlayerRecords(gameMap['gameRules']['id'], userID);

    /// Create map data to send to stream
    // TODO: later, consider storing values in widget tree and passing via GetX, or provider so we can
    // avoid using global variables
    Map<String, dynamic> gameScreenWrapperMap = {
      'ready': true,
      'gameMode': gameMode,
      'groupID': groupID,
      'id': id,
      'opponentVideo': videoURL,
      'opponentVideoAvailable': opponentVideoAvailable,
      'userID': userID,
      'fullGameMap': gameMap,
      'playerOneRecords': playerOneRecords,
    };

    /// set global data that game screen page will use
    // TODO remove usage of global data, instead use getX for state management
    await setGlobalWrapperMap('gameScreen', gameScreenWrapperMap);

    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // app moves forward
    gameScreenWrapperSink.add(gameScreenWrapperMap);
  }

  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************

  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map>(
        stream: gameScreenWrapperStream,
        initialData: {
          'ready': false,
        },
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final ready = snapshot.data!['ready'] as bool;
            final Map gameScreenWrapperMap = snapshot.data as Map;
            if (ready == true) {
              return GameScreen(gameScreenWrapperMap: gameScreenWrapperMap);
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
        }
    );
  }
}
