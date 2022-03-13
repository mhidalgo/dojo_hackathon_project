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

  /// Send open matches for judging stream to UI
  final _matchesOpenForJudgingController = StreamController<List>();
  Stream<List> get matchesOpenForJudgingStream => _matchesOpenForJudgingController.stream;
  Sink<List> get matchesOpenForJudgingSink => _matchesOpenForJudgingController.sink;

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
    _matchesOpenForJudging = databaseService.fetchMatchesForJudgingStream(globals.dojoUser.uid);

    listenForChanges();
  }

  listenForChanges() async {
    _matchesOpenForJudging.listen((event) async {
      // Map<dynamic, dynamic> matchesOpenForJudgingMap = {};
      List listOfMatchesOpenForJudging = [];
      if (event.docs.isNotEmpty) {
        /// When a matches exist, build all required data and send to the view.

        /// Store documents
        // loop through the collection of documents
        // Store each document as a list of maps
        event.docs.forEach((value)
        {
          var dataAsMap = value.data() as Map<dynamic, dynamic>;
          listOfMatchesOpenForJudging.add(dataAsMap);

        });

      } else {
        // do nothing
      }

      /// Update sink so UI updates with this data
      matchesOpenForJudgingSink.add(listOfMatchesOpenForJudging);
    });
  }
}
