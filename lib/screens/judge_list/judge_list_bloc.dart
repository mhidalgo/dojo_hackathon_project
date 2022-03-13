import 'dart:async';
import 'package:dojo_app/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';

class JudgeListBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  JudgeListBloc({required this.userID}) {
    //
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Setup variables to be passed in
  String userID;

  /// Instantiate database service object so we can perform db actions from a consolidated file
  DatabaseServices databaseService = DatabaseServices();
  late Stream<QuerySnapshot> _matchesOpenForJudging;
  late Stream<QuerySnapshot> _matchesClosedForJudging;

  /// Parameters accessible here and as getters
  late String nickname;

  void dispose() {
    _matchesOpenForJudgingController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams
  /// ***********************************************************************
  /// ***********************************************************************

  /// StreamController to manage loading required data before moving forward
  // to load level selection page
  final _judgeListWrapperController = StreamController<Map>();
  Stream<Map> get judgeListWrapperStream => _judgeListWrapperController.stream;
  Sink<Map> get judgeListWrapperSink => _judgeListWrapperController.sink;

  /// Stores stream of data for matches that are available for judging
  Stream<QuerySnapshot> get matchesOpenForJudging => _matchesOpenForJudging;

  /// Stores stream of data for matches that was judged by this user and are CLOSED
  Stream<QuerySnapshot> get matchesClosedForJudging => _matchesClosedForJudging;

  /// Send games open for judging but HAVE NOT been judged by this user yet
  final _matchesOpenForJudgingController = StreamController<List>();
  Stream<List> get matchesOpenForJudgingStream => _matchesOpenForJudgingController.stream;
  Sink<List> get matchesOpenForJudgingSink => _matchesOpenForJudgingController.sink;

  /// Send games open for judging but HAVE been judged by this user yet
  final _matchesPendingConsensusController = StreamController<List>();
  Stream<List> get matchesPendingConsensusStream => _matchesPendingConsensusController.stream;
  Sink<List> get matchesPendingConsensusSink => _matchesPendingConsensusController.sink;

  /// Send games closed that this user has succeeded in judging
  final _matchesClosedSuccessJudgementController = StreamController<List>();
  Stream<List> get matchesClosedSuccessJudgementStream => _matchesClosedSuccessJudgementController.stream;
  Sink<List> get matchesClosedSuccessJudgementSink => _matchesClosedSuccessJudgementController.sink;

  /// Send games closed that this user has failed judging
  final _matchesClosedFailedJudgementController = StreamController<List>();
  Stream<List> get matchesClosedFailedJudgementStream => _matchesClosedFailedJudgementController.stream;
  Sink<List> get matchesClosedFailedJudgementSink => _matchesClosedFailedJudgementController.sink;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Getters
  /// ***********************************************************************
  /// ***********************************************************************

  String get getNickname {
    return nickname;
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

    Map<String, dynamic> judgeListWrapper = {
      'ready': true,
    };

    await blocSetup();

    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // app moves forward
    judgeListWrapperSink.add(judgeListWrapper);
  }

  blocSetup() async {
    /// Fetch all matches open for judging
    _matchesOpenForJudging = databaseService.fetchMatchesForJudgingStream2(globals.dojoUser.uid);
    _matchesClosedForJudging = databaseService.fetchMatchesForJudgingStream3(globals.dojoUser.uid);

    listenForChanges();
  }

  listenForChanges() async {
    /// Uses the stream of data to..
    // loop through each document of this stream
    // convert to map and add to a list
    // pass this list to the screen UI to display the matches

    /// OPEN FOR USER TO JUDGE
    _matchesOpenForJudging.listen((event) async {
      printBig('outside', '1');
      List listOfMatchesOpenForJudging = [];
      List listOfMatchesPendingConsensus= [];
      if (event.docs.isNotEmpty) {
        /// When a matches exist, build all required data and send to the view.

        /// Store documents
        // loop through the collection of documents
        // Store each document as a list of maps
        event.docs.forEach((value)
        {
          var dataAsMap = value.data() as Map<dynamic, dynamic>;
          printBig('dataMap', '$dataAsMap');
          List judges = dataAsMap['judges'];

          if (judges.contains(userID)) {
           // this user has judged this game and game is OPEN
            listOfMatchesPendingConsensus.add(dataAsMap);
          } else {
            // this user has NOT judged the game and game is open
            listOfMatchesOpenForJudging.add(dataAsMap);
          }
        });
      } else {
        // do nothing
      }

      /// Update sink so UI updates with this data
      matchesOpenForJudgingSink.add(listOfMatchesOpenForJudging);
      matchesPendingConsensusSink.add(listOfMatchesPendingConsensus);
    });

    /// USER HAS JUDGED BUT CLOSED
    _matchesClosedForJudging.listen((event) async {
      printBig('outside', '1');
      List listOfGamesSuccessJudgement = [];
      List listOfGamesFailedJudgement = [];
      if (event.docs.isNotEmpty) {
        /// When a matches exist, build all required data and send to the view.

        /// Store documents
        // loop through the collection of documents
        // Store each document as a list of maps
        event.docs.forEach((value)
        {
          var dataAsMap = value.data() as Map<dynamic, dynamic>;
          List judges = dataAsMap['judges'];
          Map judgeScores = dataAsMap['judgeScores'];
          int consensusScore = dataAsMap['consensusScore'];

          if (judgeScores[userID] == consensusScore) {
            // successful judge
            listOfGamesSuccessJudgement.add(dataAsMap);
          } else if (judgeScores[userID] != consensusScore) {
            // failed judgement
            listOfGamesFailedJudgement.add(dataAsMap);
          }
        });
      } else {
        // do nothing
      }

      /// Update sink so UI updates with this data
      matchesClosedSuccessJudgementSink.add(listOfGamesSuccessJudgement);
      matchesClosedFailedJudgementSink.add(listOfGamesFailedJudgement);
    });
  }
}
