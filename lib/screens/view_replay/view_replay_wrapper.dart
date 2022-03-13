import 'dart:async';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/constants.dart' as constants;
import 'view_replay_screen.dart';

/// The purpose of Matches wrapper
// The class will obtain data that the level page requires
// while the class fetches the data, a loading screen will be displayed to the user
// once all required data is completed
// the stream in the widget is updated with this data
// which informs the app to move forward

class ViewReplayWrapper extends StatefulWidget {
  ViewReplayWrapper({
    required this.playerOneVideo,
    required this.playerOneUserID,
    required this.gameID,
    this.userPointOfView = constants.UserPointOfView.KingOfHillJudge,
    this.judgeRequestID = '0',
    this.redirect = 'MatchesWrapper()'}) {
    //
  }

  final String playerOneVideo;
  final String playerOneUserID;
  final String gameID;
  final String redirect;
  final userPointOfView;
  final String judgeRequestID;

  // determine the type of game/match we're dealing with
  late final String groupID = globals.gameModeMatchesMap['groupID']; // currently, only one groupID exists for matches for now
  late final String gameMode = 'player';  // currently, only matches supports game judging

  // Obtain this user's UID
  late final String userID = globals.dojoUser.uid;

  @override
  _ViewReplayWrapperState createState() => _ViewReplayWrapperState();
}

class _ViewReplayWrapperState extends State<ViewReplayWrapper> {
  /// ***********************************************************************
  /// Setup variables
  /// ***********************************************************************

  // Setup variables for passed in data
  late String playerOneUserID = widget.playerOneUserID;
  late String groupID = widget.groupID;
  late String gameMode = widget.gameMode;
  late String gameID = widget.gameID;
  late String redirect = widget.redirect;
  late constants.UserPointOfView userPointOfView = widget.userPointOfView;
  late String judgeRequestID = widget.judgeRequestID;

  // Initialize services required
  DatabaseServices databaseServices = DatabaseServices();

  // Initialize map to be passed to what this wraps
  late final Map viewReplayWrapperMap;

  /// StreamController to manage loading required data before moving forward
  // to load level selection page
  final _viewReplayWrapperController = StreamController<Map>();
  Stream<Map> get viewReplayWrapperStream => _viewReplayWrapperController.stream;
  Sink<Map> get viewReplayWrapperSink => _viewReplayWrapperController.sink;

  /// ***********************************************************************
  /// Initialization methods
  /// ***********************************************************************

  @override
  void initState() {
    super.initState();

    /// Primary method acting as the hub for this class
    setupViewReplayWrapper();
  }

  @override
  void dispose() {
    _viewReplayWrapperController.close();
    super.dispose();
  }

  /// ***********************************************************************
  /// Primary function
  /// ***********************************************************************

  Future<void> setupViewReplayWrapper() async {
    /// Get game document
    Map gameMap = await databaseServices.fetchGameDetailsByID(gameMode, groupID, playerOneUserID, gameID);

    /// Create map data to send to stream
    // currently, we do not use the Map's nickname or videoURL fields
    // TODO: later, consider storing values in widget tree and passing via GetX, or provider so we can
    // avoid using global variables
    viewReplayWrapperMap = {
      'ready': true,
      'gameMode': gameMode,
      'groupID': 'dummy group id',
      'playerOneUserID': playerOneUserID,
      'gameMap': gameMap,
      'redirect': redirect,
      'userPointOfView': userPointOfView,
      'judgeRequestID': judgeRequestID,
    };

    /// set global data that view_replay_screen will use
    // TODO remove usage of global data, instead use getX for state management
    await setGlobalWrapperMap('viewReplay', viewReplayWrapperMap);

    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // app moves forward
    viewReplayWrapperSink.add(viewReplayWrapperMap);
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
        stream: viewReplayWrapperStream,
        initialData: {
          'ready': false,
        },
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final ready = snapshot.data!['ready'] as bool;
            if (ready == true) {
              return ViewReplayScreen(viewReplayWrapperMap: viewReplayWrapperMap, playerOneVideo: widget.playerOneVideo);
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
