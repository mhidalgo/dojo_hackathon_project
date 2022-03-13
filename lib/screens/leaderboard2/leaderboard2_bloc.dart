import 'dart:async';
import 'package:dojo_app/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';

class Leaderboard2Bloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  Leaderboard2Bloc({required this.userID, required this.gameRulesID}) {
    //
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Setup variables to be passed in
  String userID;
  String gameRulesID;

  /// Instantiate database service object so we can perform db actions from a consolidated file
  DatabaseServices databaseService = DatabaseServices();
  late Map _userLeaderboardData;
  late Stream<QuerySnapshot> _allLeaderboardData;

  /// Parameters accessible here and as getters
  late String nickname;
  late String gameRulesTitle;

  /// Other parameters require
  late Map gameRulesMap;

  void dispose() {
    _leaderboardDataController.close();
    _leaderboardWrapperController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams
  /// ***********************************************************************
  /// ***********************************************************************

  /// StreamController to manage loading required data before moving forward
  // to load level selection page
  final _leaderboardWrapperController = StreamController<Map>();
  Stream<Map> get leaderboardWrapperStream => _leaderboardWrapperController.stream;
  Sink<Map> get leaderboardWrapperSink => _leaderboardWrapperController.sink;

  /// Stores stream of data for matches that are available for judging
  Map get userLeaderboardData => _userLeaderboardData;

  /// Stores stream of data for matches that are available for judging
  Stream<QuerySnapshot> get allLeaderboardData => _allLeaderboardData;

  /// Send open matches for judging stream to UI
  final _leaderboardDataController = StreamController<List>();
  Stream<List> get leaderboardDataStream => _leaderboardDataController.stream;
  Sink<List> get leaderboardDataSink => _leaderboardDataController.sink;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Getters
  /// ***********************************************************************
  /// ***********************************************************************

  String get getNickname {
    return nickname;
  }

  String get getGameRulesTitle {
    return gameRulesTitle;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  preloadScreenSetup() async {
    /// get nickname
    nickname = await databaseService.fetchNickname(userID: userID);
    setGlobalNickname(nickname); // store in global variable for everywhere access

    /// Get this user's leaderboard record so we can figure out what state they are in
    // pending: not confirmed by judges
    // confirmed: judges have reached consensus
    // winner: they are a winner
    // loser: they lose, but we won't handle that case for now
    _userLeaderboardData = await databaseService.getLeaderboardByUserID(userID: userID);

    // get game rules information, like title
    gameRulesMap = await databaseService.gameRules(gameRulesID: gameRulesID);
    gameRulesTitle = gameRulesMap['title'];

    await blocSetup();

    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // app moves forward to display contents of screen
    Map<String, dynamic> leaderboardWrapper = {
      'ready': true,
    };
    leaderboardWrapperSink.add(leaderboardWrapper);
  }

  blocSetup() async {
    /// Fetch all matches open for judging
    _allLeaderboardData = databaseService.getLeaderboardByGameRulesStream(gameRulesID);

    listenForChanges();
  }

  listenForChanges() async {
    _allLeaderboardData.listen((event) async {
      List listOfLeaderboardData = [];
      if (event.docs.isNotEmpty) {
        /// When leaderboard docs exist, build all required data and send to the view.

        /// Store documents
        // loop through the collection of documents
        // Store each document as a list of maps
        event.docs.forEach((value)
        {
          var dataAsMap = value.data() as Map<dynamic, dynamic>;
          listOfLeaderboardData.add(dataAsMap);

        });

      } else {
        // do nothing
      }

      /// Update sink so UI updates with this data
      leaderboardDataSink.add(listOfLeaderboardData);
    });
  }
}
