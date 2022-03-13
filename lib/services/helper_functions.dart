import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/models/game_model2.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void setGlobalUser(user) {
  globals.dojoUser = user;
}

void setGlobalNickname(nickname) async {
  globals.nickname = nickname;
}

Future<void> setGlobalWrapperMap(String type, Map dataMap) async {
  if (type == 'gameScreen') {
    globals.gameScreenWrapperMap = dataMap;
  } else if (type == 'levels') {
    globals.levelsWrapperMap = dataMap;
  } else if (type == 'matches') {
    globals.matchesWrapperMap = dataMap;
  } else if (type == 'gameModes') {
    globals.gameModesWrapperMap = dataMap;
  } else if (type == 'viewReplay') {
    globals.viewReplayWrapperMap = dataMap;
  } else if (type == 'judgeList') {
    globals.judgeListWrapperMap = dataMap;
  }

}

/// Data is initialized in game modes wrapper
// and used throughout levels
Future<void> setGlobalGameModesData(Map gameModesWrapperMap) async {
  globals.gameModesWrapperMap = gameModesWrapperMap;
}

/// Data is initialized in matches Wrapper
// and used throughout levels
Future<void> setGlobalMatchesData(Map matchesWrapperMap) async {
  globals.matchesWrapperMap = matchesWrapperMap;
}

// print big to console to help debug
void printBig(String title, String stringValue) {
  print('1***************************************************************');
  print('2*                                                             *');
  print('****        $title: $stringValue');
  print('3                                                              *');
  print('4***************************************************************');
}

String createUUID() {
  /// Generate a unique id
  var uuid = Uuid(); // create unique uuid for levelID
  String levelID = uuid.v1();
  return levelID;
}

class StreamBuilderWarningManagement extends StatelessWidget {
  StreamBuilderWarningManagement({required this.snapshot});

  final dynamic snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) {
      return Text('Contact cat support', style: Theme.of(context).textTheme.bodyText1);
    } else if (snapshot.connectionState == ConnectionState.waiting) {
      return Text('Analyzing opponents...!', style: Theme.of(context).textTheme.bodyText1);
    } else {
      return Container();
    }
  }
}

/// Determine the opponents video
// it processes a map of 0,1 or 2 items
// and returns the video that does not belong to the userID passed in
String getOpponentVideo(Map playerVideos, String userID) {
  String videoURL = '';

  // fetch video that does not belong to this user
  playerVideos.entries.forEach((e) {
    if (e.key != userID) {
      videoURL = e.value;
    }
  });

  return videoURL;
}

/// Determine the opponent's user ID from matches document
// it processes an array of 2 players
// and returns the userID that is not belonging to the userID passed in
String getOpponentUserID(matchesMap, userID) {

  String opponentUserID;
  if (matchesMap['players'][0] == userID) {
    opponentUserID = matchesMap['players'][1];
  } else {
    opponentUserID = matchesMap['players'][0];
  }

  return opponentUserID;
}

String getOpponentUserIDWithGameObject({required GameModel2 gameInfo, required String userID}) {

  String opponentUserID;
  if (gameInfo.players[0] == userID) {
    opponentUserID = gameInfo.players[1];
  } else {
    opponentUserID = gameInfo.players[0];
  }

  return opponentUserID;
}

/// Determine the opponent's user ID from gameInfo object
String getOpponentUserID2(gameInfo, userID) {

  String opponentUserID;
  if (gameInfo.players[0] == userID) {
    opponentUserID = gameInfo.players[1];
  } else {
    opponentUserID = gameInfo.players[0];
  }

  return opponentUserID;
}
