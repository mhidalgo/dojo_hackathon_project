// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:dojo_app/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/services/database_service.dart';

class JudgeListBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  JudgeListBloc({required this.userID}) {
    /// Setup game modes page
    setupGameModes();
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Setup variables to be passed in
  String userID;

  /// Instantiate database service object so we can perform db actions from a consolidated file
  DatabaseServices databaseService = DatabaseServices();
  late Stream<QuerySnapshot> _matchesOpenForJudging;

  void dispose() {
    _matchesOpenForJudgingController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams
  /// ***********************************************************************
  /// ***********************************************************************

  /// Stores stream of data for matches that are available for judging
  Stream<QuerySnapshot> get matchesOpenForJudging => _matchesOpenForJudging;

  /// Send open matches for judging stream to UI
  final _matchesOpenForJudgingController = StreamController<Map>();

  Stream<Map> get matchesOpenForJudgingStream => _matchesOpenForJudgingController.stream;
  Sink<Map> get matchesOpenForJudgingSink => _matchesOpenForJudgingController.sink;

  /*
  /// OpponentDetail Widget Controller
  final _matchAlertsController = StreamController<Widget>();
  Stream<Widget> get matchAlertsStream => _matchAlertsController.stream;
  Sink<Widget> get matchAlertsSink => _matchAlertsController.sink;*/

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  setupGameModes() {
    /// Fetch all matches open for judging
    _matchesOpenForJudging = databaseService.fetchMatchesForJudgingStream(globals.dojoUser.uid);

    listenForChanges();
  }

  listenForChanges() async {
    _matchesOpenForJudging.listen((event) async {
      Map<dynamic, dynamic> matchesOpenForJudgingMap = {};
      if (event.docs.isNotEmpty) {
        /// When a matches exist, build all required data and send to the view.

        /// Store documents

        // loop through each document
        // Store each document as a list of maps
        //matchesOpenForJudgingMap = event.docs.first.data() as Map<dynamic, dynamic>;
        List listOfMatchesOpenForJudging = [];
        event.docs.forEach((value)
        {
          var dataAsMap = value.data() as Map<dynamic, dynamic>;
          listOfMatchesOpenForJudging.add(dataAsMap);

        });

      } else {
        // do nothing
      }

      /// Update sink so UI updates with this data
      matchesOpenForJudgingSink.add(matchesOpenForJudgingMap);
    });
  }
}
