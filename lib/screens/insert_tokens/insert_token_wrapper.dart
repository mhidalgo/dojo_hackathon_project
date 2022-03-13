import 'dart:async';
import 'package:dojo_app/screens/game/game_screen.dart';
import 'package:dojo_app/screens/insert_tokens/insert_tokens_screen.dart';
import 'package:dojo_app/services/match_service.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:flutter/material.dart';


class InsertTokenWrapper extends StatefulWidget {
  InsertTokenWrapper({
    required this.userID,
  required this.gameRulesID,
  required this.gameMap}) {
    //
  }

  final dynamic userID;
  final String gameRulesID;
  final Map gameMap;

  @override
  _InsertTokenWrapperState createState() => _InsertTokenWrapperState();
}

class _InsertTokenWrapperState extends State<InsertTokenWrapper> {
  /// ***********************************************************************
  /// Setup variables
  /// ***********************************************************************

  // Setup variables for passed in data
  late String userID = widget.userID;
  late String gameRulesID = widget.gameRulesID;
  late Map gameMap = widget.gameMap;

  // Manages whether an opponent video is displayed or not
  DatabaseServices databaseServices = DatabaseServices();

  late Map<String, dynamic> insertTokenScreenWrapperMap;

  /// StreamController to manage loading required data before moving forward
  // to load game screen page
  final _insertTokenScreenWrapperController = StreamController<Map>();
  Stream<Map> get insertTokenScreenWrapperStream => _insertTokenScreenWrapperController.stream;
  Sink<Map> get insertTokenScreenWrapperSink => _insertTokenScreenWrapperController.sink;

  /// ***********************************************************************
  /// Initialization methods
  /// ***********************************************************************

  @override
  void initState() {
    super.initState();

    /// Primary method acting as the hub
    setup();
  }

  @override
  void dispose () {
    _insertTokenScreenWrapperController.close();
    super.dispose();
  }

  /// ***********************************************************************
  /// Primary function
  /// ***********************************************************************

  void setup() async {
    Map gameInfo = await databaseServices.fetchLatestStartingGameDetails2(userID: widget.userID, gameRulesID: widget.gameRulesID);
    bool paymentReceived = gameInfo['paymentReceived'];

    /// Create map data to send to stream
    // TODO: later, consider storing values in widget tree and passing via GetX, or provider so we can
    // avoid using global variables
    insertTokenScreenWrapperMap = {
      'ready': true,
      'gameRulesID': gameRulesID,
      'userID': userID,
      'gameMap': gameInfo,
      'paymentReceived': paymentReceived,
    };

    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // app moves forward
    insertTokenScreenWrapperSink.add(insertTokenScreenWrapperMap);

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
        stream: insertTokenScreenWrapperStream,
        initialData: {
          'ready': false,
        },
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final ready = snapshot.data!['ready'] as bool;
            if (ready == true) {
              return InsertTokenScreen(insertTokenScreenWrapperMap: insertTokenScreenWrapperMap);
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
