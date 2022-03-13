// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/services/database_service.dart';

class GameModesBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  GameModesBloc({required this.userID}) {

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
  // late Stream<QuerySnapshot> _gameModesStream;

  void dispose() {
    /*_matchAlertsController.close();
    _gameModesListController.close();*/
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams
  /// ***********************************************************************
  /// ***********************************************************************

  /*/// Stream for the view so it can display list of level cards to user
  Stream<QuerySnapshot> get gameModesStream => _gameModesStream;

  /// StreamController listens for level cards to display
  final _gameModesListController = StreamController<Map>();
  Stream<Map> get gameModesListStream => _gameModesListController.stream;
  Sink<Map> get _gameModesListSink => _gameModesListController.sink;

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
    //
  }
}