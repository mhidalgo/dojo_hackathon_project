import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/models/game_model.dart';
import 'package:dojo_app/models/game_model2.dart';
import 'package:dojo_app/models/game_model2_extras.dart';
import 'package:dojo_app/models/video_model.dart';
import 'package:dojo_app/services/game_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'background_upload_service.dart';
import 'helper_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dojo_app/constants.dart' as constants;
import 'dart:io';
import 'package:intl/intl.dart';


class DatabaseServices {
  /// ***********************************************************************
  /// ***********************************************************************
  /// User
  /// ***********************************************************************
  /// ***********************************************************************

  /// Obtain nickname based on userID
  Future<String> fetchNickname({userID}) async {
    final nicknameQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('User_ID', isEqualTo: userID)
        .get();

    if (nicknameQuery.docs.isEmpty) {
      return 'Player';
    } else {
      var result = nicknameQuery.docs.first.data();
      return result['Nickname'];
    }
  }

  /// Obtain user info based on userID
  Future<Map> fetchUserInfo({userID}) async {
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('User_ID', isEqualTo: userID)
        .get();

    if (userQuery.docs.isEmpty) {
      return {};
    } else {
      var result = userQuery.docs.first.data();
      return result;
    }
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Levels: Get Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get all levels for a specific levelGroup
  Stream<QuerySnapshot> fetchLevelsByLevelGroup(String levelGroupID, String userID) {
    return FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID) // userID as collection name
        .orderBy('level', descending: false)
        .snapshots();
  }

  /// Obtain opponent details of a specific level
  // used by gameMode levels only
  Future<QuerySnapshot<Map<String, dynamic>>> fetchSingleGameDetails({gameMode, id, groupID, userID}) async {
    final gameQuery = await FirebaseFirestore.instance
        .collection('$gameMode')
        .doc(groupID)
        .collection(userID)
        .where('id', isEqualTo: id)
        .get();

    return gameQuery;
  }

  /// After the user wins a level, get the next levelID to update so that it's unlocked
  Future<String> fetchNextLevelID({required String levelGroupID, required String userID, required int level}) async {
    final nextLevelQuery = await FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID)
        .where('level', isGreaterThanOrEqualTo: level)
        .orderBy('level')
        .limit(2)
        .get();

    /// Determine if 2 documents come back
    // the 2nd document is the next active level
    // if the length is 1, then there is no next level available yet
    dynamic result2 = nextLevelQuery.docs.length;

    // set result to be the last document from the collection
    dynamic result = nextLevelQuery.docs.last.data();
    String newLevelID = result['id'];
    return newLevelID;
  }

  /// Obtain video background for level page
  Future<String> fetchLevelSelectBackgroundVideo({levelGroupID, userID}) async {
    String videoURL = '';

    final levelQuery = await FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID)
        .where('status', isEqualTo: 'active')
        .get();

    /// return the video of any active level
    // or if they beat all the levels (no docs returned above, then return a celebration video
    if (levelQuery.docs.isEmpty) {
      Map levelDetailMap = await fetchLevelDetails(levelGroupID: levelGroupID);
      var defaultVideo = levelDetailMap['allLevelsCompletedVideo'];
      return defaultVideo;
    } else {
      var result = levelQuery.docs.first.data();

      // find video that isn't their own
      Map playerVideos = result['playerVideos'];
      videoURL = getOpponentVideo(playerVideos, userID);

      return videoURL;
    }
  }

  /// Obtain video background for level page
  Future<String> fetchGameModeBackgroundVideo({levelGroupID, userID}) async {
    String videoURL = '';

    final levelQuery = await FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID)
        .where('status', isEqualTo: 'active')
        .get();

    /// return the video of any active level
    // or if they beat all the levels (no docs returned above, then return a celebration video
    if (levelQuery.docs.isEmpty) {
      Map levelDetailMap = await fetchLevelDetails(levelGroupID: levelGroupID);
      var defaultVideo = levelDetailMap['allLevelsCompletedVideo'];
      return defaultVideo;
    } else {
      var result = levelQuery.docs.first.data();

      // find video that isn't their own
      Map playerVideos = result['playerVideos'];
      videoURL = getOpponentVideo(playerVideos, userID);

      return videoURL;
    }
  }

  /// Obtain level details
  Future<Map> fetchLevelDetails({levelGroupID}) async {
    final levelDetailsQuery = await FirebaseFirestore.instance
        .collection('levels')
        .where('groupID', isEqualTo: levelGroupID)
        .get();

    var result = levelDetailsQuery.docs.first.data();
    return result;
  }

  /// query database and see if they have any levels associated with their account
  Future<bool> hasLevelsForThisLevelGroupCheck({levelGroupID, userID}) async {
    final userCollection = await FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID)
        .limit(1)
        .get();

    // returns true if they do not have levels associated their their account yet
    // returns false if they have levels for this levelGroup
    return (userCollection.docs.isEmpty);
  }

  /// query database and see if they completed all levels for a specific levelGroup
  Future<bool> hasUserCompletedAllLevels({levelGroupID, userID}) async {
    final userCollection = await FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    // returns true if all levels are completed
    // returns false if they have at least one level that is active
    return (userCollection.docs.isEmpty);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Levels: Save Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get data from levelTemplates and save to a user's levels collection
  copyLevelsToUserAccount({levelGroupID, userID, nickname}) async {
    final retrieveLevelTemplates = await FirebaseFirestore.instance
        .collection('levelTemplates')
        .doc(levelGroupID)
        .collection('levelTemplates.templates')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {

        /// Generate a unique id for the level
        String levelID = createUUID();

        /// Iterate through each document field and create a map
        // first convert document into a map
        Map<String, dynamic> levelTemplateData = doc.data() as Map<String, dynamic>;

        /// dynamically populate the levelData map with results from Firebase
        Map<String, dynamic> levelData = {};
        for (String key in levelTemplateData.keys){
          levelData[key] = levelTemplateData[key];
        }

        /// Add additional data that is not part of the level template document
        levelData["dateCreated"] = DateTime.now();
        levelData["id"] = levelID;
        levelData["players"].add(userID);
        levelData["playerNicknames"][userID] = nickname;

        /// Obtain opponentID
        String playerTwoUserID = getOpponentUserID(levelData, userID);

        /// Add player sub scores
        // Create map for playerSubScores
        Map<String, int> playerOneSubScores = {
          "reps": 0,
          "form": 0,
          "sleep": 0,
          "nutrition": 0,
        };

        Map<String, int> playerTwoSubScores = {
          "reps": levelData['levelGoal'],
          "form": 0,
          "sleep": 0,
          "nutrition": 0,
        };

        levelData["playerSubScores"] = {
          userID: playerOneSubScores,
          playerTwoUserID: playerTwoSubScores,
        };

        /// save the level to the user's collection
        await FirebaseFirestore.instance
            .collection('levels')
            .doc(levelGroupID)
            .collection(userID)
            .doc(levelID)
            .set(levelData);
      });
    });
  } // end addLevelsToUserAccount

  /// update levels > level document... if they won
  void updateActiveLevelForAWinner({required GameModel2 gameInfo, required GameModel2Extras gameInfoExtras}) async {
    // Extract required data
    String levelGroupID = gameInfo.groupID;
    String levelID = gameInfo.id;
    String userID = gameInfoExtras.playerOneUserID;
    String gameStatus = gameInfo.gameStatus;
    Map playerScores = gameInfo.playerScores; // final score
    Map playerVideos = gameInfo.playerVideos; // final video
    Map playerGameOutcomes = gameInfo.playerGameOutcomes;

    DocumentReference updateExistingLevel = FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID)
        .doc(levelID);

    /// IF user won, then update active level
    updateExistingLevel.update({
      "playerScores": playerScores,
      "playerVideos": playerVideos,
      "playerGameOutcomes": playerGameOutcomes,
      "gameStatus": gameStatus,
      "dateUpdated": DateTime.now(),
      "status": 'completed',
    }); // end
  }

  void updateLevelWithGameData({required GameModel2 gameInfo, required GameModel2Extras gameInfoExtras}) async {
    // Extract required data from gameInfo
    String levelGroupID = gameInfo.groupID;
    String levelID = gameInfo.id;
    String userID = gameInfoExtras.playerOneUserID;
    int score = gameInfo.playerScores[userID];
    String gameID = gameInfo.id;

    /// obtain active level collection and locate the specific document
    final userLevelQuery = await FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID)
        .where('id', isEqualTo: levelID)
        .get();

    // there should only be one result so set result to this document
    var result = userLevelQuery.docs.first.data();

    /// Declare empty maps
    Map scoresMap = {}; // stores all scores recorded for this level
    //Map videosMap = {}; // stores all videos recorded for this level

    /// handle case where userLevelQuery doesn't have this field created yet
    // (ex. map won't exist when a user plays a levelGroup's level for the first time)
    if (result.containsKey('gameScores')) {
      // field exists so obtain their existing values so we can append to it
      scoresMap = result['gameScores'] as Map;
    }

    /*if (result.containsKey('gameVideos')) {
      // field exists so obtain their existing values so we can append to it
      videosMap = result['gameVideos'] as Map;
    }*/

    /// Update map with additional values
    scoresMap[gameID] = score;
    //videosMap[gameID] = currentPlayerVideoURL;

    /// Update level document with these values
    // create document reference
    DocumentReference levelReference = FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID)
        .doc(levelID);

    // update document
    await levelReference.update({
      "gameScores": scoresMap,
      //"gameVideos": videosMap,
      'dateUpdated': DateTime.now(),
    }); // end
  }

  /// locate the next level document that requires updating
  // the following returns the next levelID
  // if there no next level, it will return the same exact ID you pass it
  void updateNextLevelForAWinner({required GameModel2 gameInfo, required GameModel2Extras gameInfoExtras}) async {
    // Extract required data from GameInfo
    String levelGroupID = gameInfo.groupID;
    String levelID = gameInfo.id;
    String userID = gameInfoExtras.playerOneUserID;
    int level = gameInfo.level;

    dynamic nextLevelID;
    nextLevelID = await fetchNextLevelID(
        levelGroupID: levelGroupID,
        userID: userID,
        level: level);

    /// Only update if a next level exists
    // if the levelID passed in matches the levelID returned from nextLevelID, then no next level exists
    if (levelID != nextLevelID) {
      /// Set this next level's status as active
      DocumentReference updateExistingGame2 = FirebaseFirestore.instance
          .collection('levels')
          .doc(levelGroupID)
          .collection(userID)
          .doc(nextLevelID);

      /// IF user won, then update next level
      await updateExistingGame2.update({
        "dateUpdated": DateTime.now(),
        "status": 'active',
      }); // end
    } else {
      printBig('do not update, existing levelID', '$nextLevelID');
    }
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Matches, Get Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get STREAM: details for a single match
  // unused
  Stream<QuerySnapshot> fetchLatestSingleGameDetailsStream(String gameMode, String matchGroupID, String userID) {
    return FirebaseFirestore.instance
        .collection('$gameMode')
        .doc(matchGroupID)
        .collection(userID) // userID as collection name
        .orderBy('dateUpdated', descending: true)
        .snapshots();
  }

  /// Get STREAM: details for a single match
  // unused
  Stream<QuerySnapshot> fetchLatestSingleGameDetailsStreamFlat(String gameMode, String matchGroupID, String userID) {
    return FirebaseFirestore.instance
        .collection('matchesAll')
        .where('players', arrayContains: userID)
        .orderBy('dateUpdated', descending: true)
        .snapshots();
  }

  /// Get STREAM: details for a single match
  Stream<QuerySnapshot> fetchLatestStartingGamesStream(String gameMode, String matchGroupID, String userID) {
    return FirebaseFirestore.instance
        .collection('$gameMode')
        .doc(matchGroupID)
        .collection(userID) // userID as collection name
        .where('dateStart', isLessThanOrEqualTo: DateTime.now())
        .orderBy('dateStart', descending: true)
        .snapshots();
  }

  /// Get STREAM: details for a single match
  // unused
  Stream<QuerySnapshot> fetchLatestStartingGameDetailsStreamFlat(String gameMode, String matchGroupID, String userID) {
    return FirebaseFirestore.instance
        .collection('matchesAll')
        .where('players', arrayContains: userID)
        .where('dateStart', isLessThanOrEqualTo: DateTime.now())
        .orderBy('dateUpdated', descending: true)
        .snapshots();
  }

  /// Get SNAPSHOT: details for a single match
  // unused
  Future<QuerySnapshot> fetchLatestSingleGameDetails(String gameMode, String matchGroupID, String userID) async {
    final matchDetailQuery = await FirebaseFirestore.instance
        .collection('$gameMode')
        .doc(matchGroupID)
        .collection(userID) // userID as collection name
        .orderBy('dateUpdated', descending: true)
        .get();

    var result;
    result = matchDetailQuery;
    return result;
  }

  /// Get SNAPSHOT: details for a single match
  Future<QuerySnapshot> fetchLatestStartingGameDetails(String gameMode, String matchGroupID, String userID) async {
    final matchDetailQuery = await FirebaseFirestore.instance
        .collection('$gameMode')
        .doc(matchGroupID)
        .collection(userID) // userID as collection name
        .where('dateStart', isLessThanOrEqualTo: DateTime.now())
        .orderBy('dateStart', descending: true)
        .get();

    var result;
    result = matchDetailQuery;
    return result;
  }

  /// Get SNAPSHOT: details for a single match
  Future<Map> fetchLatestStartingGameDetails2({required String userID, required String gameRulesID}) async {
    final matchDetailQuery = await FirebaseFirestore.instance
        .collection('matchesAll2')
        .where('userID', isEqualTo: userID)
        .where('gameRulesID', isEqualTo: gameRulesID)
        .orderBy('dateCreated', descending: true)
        .get();

    Map<dynamic, dynamic> result;
    if (matchDetailQuery.docs.isNotEmpty) {
      result = matchDetailQuery.docs.first.data();
    } else {
      result = {};
    }

    return result;
  }

  /// Get MAP: details for a single match by ID
  // used by view replay only
  Future<Map> fetchGameDetailsByID(String gameMode, String matchGroupID, String userID, String id) async {
    final matchDetailQuery = await FirebaseFirestore.instance
        .collection('matchesAll2')
        .where('id', isEqualTo: id)
        //.orderBy('dateUpdated', descending: true)
        .get();

    var result = matchDetailQuery.docs.first.data();
    return result;
  }

  /// **********************************************************************
  ///
  ///

  /// Get SNAPSHOT: details for a single match
  Future<Map> gameRules({required String gameRulesID}) async {
    final gameRulesQuery = await FirebaseFirestore.instance
        .collection('gameRules')
        .where('id', isEqualTo: gameRulesID)
        .get();

    Map<dynamic, dynamic> result;
    if (gameRulesQuery.docs.isNotEmpty) {
      result = gameRulesQuery.docs.first.data();
    } else {
      result = {};
    }

    return result;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Matches: Save Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Create match for Marvin and Van
  Future<void> createMatchForMV(gameInfo) async {
    /// save the level to the user's collection
    await FirebaseFirestore.instance
        .collection('matches')
        .doc(gameInfo['groupID'])
        .collection(gameInfo['userID'])
        .doc(gameInfo['id'])
        .set(gameInfo);
  }

  /// Create match for Marvin and Van
  Future<void> createMatchForMVFlat(gameInfo) async {
    /// save the level to the user's collection
    await FirebaseFirestore.instance
        .collection('matchesAll')
        .doc(gameInfo['id'])
        .set(gameInfo);
  }

  /// Create match for Marvin and Van
  Future<void> createGame(gameInfo) async {
    /// save the level to the user's collection
    await FirebaseFirestore.instance
        .collection('matchesAll2')
        .doc(gameInfo['id'])
        .set(gameInfo);
  }

  /// Update match document
  // uses GameModel2 which is a replica of the match document model
  // uses GameModel2Extras which contains extra data that is useful for matches
  void updateMatches(GameModel2 gameInfo, GameModel2Extras gameInfoExtras) async {
    // Extract required data
    String groupID = gameInfo.groupID;
    String id = gameInfo.id;
    String playerOneUserID = gameInfoExtras.playerOneUserID;
    String playerTwoUserID = gameInfoExtras.playerTwoUserID;
    String gameStatus = gameInfo.gameStatus;
    Map playerScores = gameInfo.playerScores;
    Map playerGameOutcomes = gameInfo.playerGameOutcomes;
    Map questions = gameInfo.questions;
    Map judging = gameInfo.judging;
    Map playerSubScores = gameInfo.playerSubScores;
    Map dates = gameInfo.dates;

    /// Update for this user
    DocumentReference updateMatchForThisUser = FirebaseFirestore.instance
        .collection('matches')
        .doc(groupID)
        .collection(playerOneUserID)
        .doc(id);

    updateMatchForThisUser.update({
      "playerScores": playerScores,
      "playerGameOutcomes": playerGameOutcomes,
      "dateUpdated": DateTime.now(),
      "gameStatus": gameStatus,
      "questions": questions,
      "judging": judging,
      "playerSubScores": playerSubScores,
      "dates": dates,
    }); // end

    /// Update for opponent
    DocumentReference updateMatchForOpponent = FirebaseFirestore.instance
        .collection('matches')
        .doc(groupID)
        .collection(playerTwoUserID)
        .doc(id);

    updateMatchForOpponent.update({
      "playerScores": playerScores,
      "playerGameOutcomes": playerGameOutcomes,
      "dateUpdated": DateTime.now(),
      "gameStatus": gameStatus,
      "questions": questions,
      "judging": judging,
      "playerSubScores": playerSubScores,
      "dates": dates,
    }); // end
  }

  /// Update match document
  // uses GameModel2 which is a replica of the match document model
  // uses GameModel2Extras which contains extra data that is useful for matches
  void updateMatchesFlat(GameModel2 gameInfo, GameModel2Extras gameInfoExtras) async {
    // Extract required data
    String id = gameInfo.id;
    String gameStatus = gameInfo.gameStatus;
    Map playerScores = gameInfo.playerScores;
    Map playerGameOutcomes = gameInfo.playerGameOutcomes;
    Map questions = gameInfo.questions;
    Map judging = gameInfo.judging;
    Map playerSubScores = gameInfo.playerSubScores;
    Map dates = gameInfo.dates;

    /// Obtain reference for match document that will be updated
    DocumentReference updateMatch = FirebaseFirestore.instance
        .collection('matchesAll2')
        .doc(id);

    updateMatch.update({
      "playerScores": playerScores,
      "playerGameOutcomes": playerGameOutcomes,
      "dateUpdated": DateTime.now(),
      "gameStatus": gameStatus,
      "questions": questions,
      "judging": judging,
      "playerSubScores": playerSubScores,
      "dates": dates,
    }); // end
  }

  /// Called as part of the process when a player forfeits
  Future<void> updateForfeitedMatch(Map matchDetails) async {
    /// Set reference for player 1 match doc (this player)
    DocumentReference updateMatchForPlayer0 = FirebaseFirestore.instance
        .collection(matchDetails['gameMode'])
        .doc(matchDetails['groupID'])
        .collection(matchDetails['players'][0])
        .doc(matchDetails['id']);

    /// Update for player 1 (this player)
    updateMatchForPlayer0.update({
      "playerGameOutcomes": matchDetails['playerGameOutcomes'],
      "playerScores": matchDetails['playerScores'],
      "gameStatus": matchDetails['gameStatus'],
      "dateUpdated": DateTime.now(),
    });

    /// Set reference for player 2 match document (opponent)
    DocumentReference updateMatchForPlayer1 = FirebaseFirestore.instance
        .collection(matchDetails['gameMode'])
        .doc(matchDetails['groupID'])
        .collection(matchDetails['players'][1])
        .doc(matchDetails['id']);

    /// Update for player 2 (opponent)
    updateMatchForPlayer1.update({
      "playerGameOutcomes": matchDetails['playerGameOutcomes'],
      "playerScores": matchDetails['playerScores'],
      "gameStatus": matchDetails['gameStatus'],
      "dateUpdated": DateTime.now(),
    });
  }

  /// Called as part of the process when a player forfeits
  Future<void> updateForfeitedMatchFlat(Map matchDetails) async {
    /// Set reference to match document
    DocumentReference updateMatch = FirebaseFirestore.instance
        .collection('matchesAll')
        .doc(matchDetails['id']);

    /// Update match document
    updateMatch.update({
      "playerGameOutcomes": matchDetails['playerGameOutcomes'],
      "playerScores": matchDetails['playerScores'],
      "gameStatus": matchDetails['gameStatus'],
      "dateUpdated": DateTime.now(),
    });
  }

  /// ***********************************************************************
  /// Matches - Judging: Save Data
  /// ***********************************************************************

  void updateMatchWithJudgingStatus(Map matchInfo, String _judgingStatus, String _playerOneUserID, String _playerTwoUserID) async {
    // Extract required data
    String groupID = matchInfo['groupID'];
    String id = matchInfo['id'];
    String playerOneUserID = _playerOneUserID;
    String playerTwoUserID = _playerTwoUserID;
    Map judging = matchInfo['judging'];
    Map dates = matchInfo['dates'];

    /// Set updated secondary gameStatus
    judging['status'] = _judgingStatus;

    /// Set dateUpdated
    judging['dateUpdated'] = DateTime.now();

    /// Set when judging was specifically updated
    // discord bot uses this to determine what changed last about a match
    dates['judgingUpdated'] = DateTime.now();

    /// Update for this user
    DocumentReference updateMatchForThisUser = FirebaseFirestore.instance
        .collection('matches')
        .doc(groupID)
        .collection(playerOneUserID)
        .doc(id);

    updateMatchForThisUser.update({
      "judging": judging,
      "dateUpdated": DateTime.now(),
      "dates": dates,
    }); // end

    /// Update for opponent
    DocumentReference updateMatchForOpponent = FirebaseFirestore.instance
        .collection('matches')
        .doc(groupID)
        .collection(playerTwoUserID)
        .doc(id);

    updateMatchForOpponent.update({
      "judging": judging,
      "dateUpdated": DateTime.now(),
      "dates": dates,
    }); // end
  }

  void updateMatchWithJudgingStatusFlat(Map matchInfo, String _judgingStatus, String _playerOneUserID, String _playerTwoUserID) async {
    // Extract required data
    String id = matchInfo['id'];
    Map judging = matchInfo['judging'];
    Map dates = matchInfo['dates'];

    /// Set updated secondary gameStatus
    judging['status'] = _judgingStatus;

    /// Set dateUpdated
    judging['dateUpdated'] = DateTime.now();

    /// Set when judging was specifically updated
    // discord bot uses this to determine what changed last about a match
    dates[constants.cJudgingUpdated] = DateTime.now();

    /// Update for this user
    DocumentReference updateMatch = FirebaseFirestore.instance
        .collection('matchesAll')
        .doc(id);

    updateMatch.update({
      "judging": judging,
      "dateUpdated": DateTime.now(),
      "dates": dates,
    }); // end
  }

  /// ***********************************************************************
  /// Matches - Video, Food: Save Data
  /// ***********************************************************************

  /// Update match or level collection with player videos
  Future<void> updateLevelOrMatchWithVideoURL(gameMode, groupID, id, userID, videoOwnerUserID, videoURL) async {
    /// Fetch data
    final gameQuery = await FirebaseFirestore.instance
        .collection('$gameMode')
        .doc(groupID)
        .collection(userID)
        .where('id', isEqualTo: id)
        .get();

    if (gameQuery.docs.isNotEmpty) {
      var result = gameQuery.docs.first.data();
      Map playerVideoMap = result['playerVideos'];

      /// Update Map with this user's video
      playerVideoMap[videoOwnerUserID] = videoURL;

      /// Update userID's document
      DocumentReference updateGameForThisUser = FirebaseFirestore.instance
          .collection('$gameMode')
          .doc(groupID)
          .collection(userID)
          .doc(id);

      updateGameForThisUser.update({
        "playerVideos": playerVideoMap,
      }); // end
    }
  }

  /// Update match or level collection with player videos
  Future<void> updateMatchWithVideoURLFlat(gameMode, groupID, id, userID, videoOwnerUserID, videoURL) async {
    /// Fetch data
    final gameQuery = await FirebaseFirestore.instance
        .collection('matchesAll2')
        .where('id', isEqualTo: id)
        .get();

    if (gameQuery.docs.isNotEmpty) {
      var result = gameQuery.docs.first.data();
      Map playerVideoMap = result['playerVideos'];

      /// Update Map with this user's video
      playerVideoMap[videoOwnerUserID] = videoURL;

      /// Update userID's document
      DocumentReference updateMatch = FirebaseFirestore.instance
          .collection('matchesAll2')
          .doc(id);

      updateMatch.update({
        "playerVideos": playerVideoMap,
      }); // end
    }
  }

  Future<void> saveFoodImageURLtoMatch({required Map picMap, required String groupID, required String userID, required String matchID, required Map dates}) async {
    await FirebaseFirestore.instance
        .collection('matches')
        .doc(groupID)
        .collection(userID)
        .doc(matchID)
        .update({
          'playerFoodPics':FieldValue.arrayUnion([picMap]),
          'dateUpdated': DateTime.now(),
          'dates': dates,
    });
  }

  Future<void> saveFoodImageURLtoMatchFlat({required Map picMap, required String matchID, required Map dates}) async {
    await FirebaseFirestore.instance
        .collection('matchesAll')
        .doc(matchID)
        .update({
      'playerFoodPics':FieldValue.arrayUnion([picMap]),
      'dateUpdated': DateTime.now(),
      'dates': dates,});
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Judging: Get Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get matches that have requested 3rd party judging and are still open
  Future<QuerySnapshot> fetchMatchesForJudging(String userID) async {
    final matchesForJudging = await FirebaseFirestore.instance
        .collection('judging')
    //.where('userAccess', arrayContains: userID)
        .where('status', isEqualTo: constants.cJudgeMatchStatusOpen)
    //.orderBy('dateUpdated', descending: false)
        .get();

    var result;
    result = matchesForJudging;
    return result;
  }

  Stream<QuerySnapshot> fetchMatchesForJudgingStream(String userID) {
    final Stream<QuerySnapshot> matchesForJudging = FirebaseFirestore.instance
        .collection('judging')
    //.where('userAccess', arrayContains: userID)
        .where('status', isEqualTo: constants.cJudgeMatchStatusOpen)
    //.orderBy('dateUpdated', descending: false)
        .snapshots();

    var result;
    result = matchesForJudging;
    return result;
  }

  /// Games that a user has NOT judged, and is open
  Stream<QuerySnapshot> fetchMatchesForJudgingStream2(String userID) {
    printBig('userID judge', '$userID');
    final Stream<QuerySnapshot> matchesForJudging = FirebaseFirestore.instance
        .collection('judging2')
        //.where('judgesUserID', arrayContains: userID)
        .where('status', isEqualTo: constants.cJudgeMatchStatusOpen)
    //.orderBy('dateUpdated', descending: false)
        .snapshots();

    var result;
    result = matchesForJudging;
    return result;
  }

  /// Games that a user has judged, and is closed
  Stream<QuerySnapshot> fetchMatchesForJudgingStream3(String userID) {
    printBig('userID judge', '$userID');
    final Stream<QuerySnapshot> matchesForJudging = FirebaseFirestore.instance
        .collection('judging2')
        .where('judges', arrayContains: userID)
        .where('status', isEqualTo: constants.cJudgeMatchStatusClosed)
    //.orderBy('dateUpdated', descending: false)
        .snapshots();

    var result;
    result = matchesForJudging;
    return result;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Judging: Save Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Create doc signaling a 3rd party judge is requested
  Future<void> create3rdPartyJudgeRequest(gameMap) async {
    // set data to be saved
    Map<String, dynamic> gameInfo = {};
    gameInfo['id'] = createUUID();
    gameInfo['dateCreated'] = DateTime.now();
    gameInfo['dateUpdated'] = DateTime.now();
    gameInfo['gameID'] = gameMap['id'];
    gameInfo['playerNicknames'] = gameMap['playerNicknames'];
    gameInfo['playerScores'] = gameMap['playerScores'];
    gameInfo['playerVideos'] = gameMap['playerVideos'];
    gameInfo['players'] =  gameMap['players'];
    gameInfo['status'] = 'open';
    gameInfo['userAccess'] = ['AI22rzMxuphgmK5Zr8lVGht3O3D3', 'eKv2KuKDJNNba7OUy1SNo3ilfiq2', 'RRmF9OaRW1Ue6kHtczyILqq9Fyc2', 'IaNoVdiaMtWiiyD7HFlRf5MqqSE3','6n5A87DnNMNdj0qOtjemKS5CYn43', 'OUbllyr5PzfsYzFlXxyrSvjF8hm1'];

    // save data to firebase
    await FirebaseFirestore.instance
        .collection('judging')
        .doc(gameInfo['id'])
        .set(gameInfo);
  }

  /// Create doc signaling a 3rd party judge is requested
  Future<void> create3rdPartyJudgeRequest2(gameMap) async {
    // set data to be saved
    Map<String, dynamic> gameInfo = {};
    gameInfo['consensusScore'] = 0;
    gameInfo['id'] = createUUID();
    gameInfo['dateCreated'] = DateTime.now();
    gameInfo['dateUpdated'] = DateTime.now();
    gameInfo['gameID'] = gameMap['id'];
    gameInfo['playerNicknames'] = gameMap['playerNicknames'];
    gameInfo['playerScores'] = gameMap['playerScores'];
    gameInfo['playerVideos'] = gameMap['playerVideos'];
    gameInfo['players'] =  gameMap['players'];
    gameInfo['status'] = 'open';
    gameInfo['gameMode'] =  gameMap['gameMode'];
    gameInfo['gameRulesID'] =  gameMap['gameRulesID'];
    gameInfo['originalScore'] =  gameMap['playerScores'][gameMap['userID']];
    gameInfo['judges'] = [];
    gameInfo['judgeCount'] = 0;
    gameInfo['judgeScores'] = {};
    gameInfo['gameTitle'] = gameMap['gameRules']['title'];

    // save data to firebase
    await FirebaseFirestore.instance
        .collection('judging2')
        .doc(gameInfo['id'])
        .set(gameInfo);
  }

  /// Update judge document with a new judges information
  Future<void> updateJudgingRequest(id, judgeMap, userID, score) async {
    /// Update for this user
    DocumentReference updateMatchForThisUser = FirebaseFirestore.instance
        .collection('judging2')
        .doc(id);

    List judges = judgeMap['judges'];
    int judgeCount = judgeMap['judgeCount'];
    Map judgeScores = judgeMap['judgeScores'];

    judges.add(userID); // list of judges
    judgeCount = judgeCount + 1; // number of judges who have judged
    judgeScores[userID] = score;  // add judges score to document

    updateMatchForThisUser.update({
      "judgeUserID": constants.cJudgeMatchStatusClosed,
      'judgeCount': judgeCount,
      'judgeScores': judgeScores
    }); // end
  }

  void closeJudgingRequest(String id, String userID, String nickname) {
    /// Update for this user
    DocumentReference updateMatchForThisUser = FirebaseFirestore.instance
        .collection('judging')
        .doc(id);

    // Save signature of judge closing the request
    Map judgeSignature = {
      'userID': userID,
      'nickname': nickname,
    };

    updateMatchForThisUser.update({
      "status": constants.cJudgeMatchStatusClosed,
      'judgeSignature': judgeSignature,
    }); // end
  }

  void updateJudgingWithScore({required Map judgeScores, required List judges, required String id}) async {
    /// Fetch judge doc

    /// Update for this user
    DocumentReference updateMatchForThisUser = FirebaseFirestore.instance
        .collection('judging2')
        .doc(id);

    updateMatchForThisUser.update({
      "judgeScores": judgeScores,
      'judges': judges,
    }); // end
  }

  /// Obtain scores for 60 second match
  Future<Map> getJudge({required String id}) async {
    Map result = {};

    final judgeRecordsQuery = await FirebaseFirestore.instance
        .collection('judging2')
        .where('id', isEqualTo: id)
        .get();

    if (judgeRecordsQuery.docs.isNotEmpty) {
      result = judgeRecordsQuery.docs.first.data();
    }

    return result;
  }

  void updateJudgingWithConsensus({required int consensusScore, required String id}) async {
    /// Update for this user
    DocumentReference updateMatchForThisUser = FirebaseFirestore.instance
        .collection('judging2')
        .doc(id);

    updateMatchForThisUser.update({
      "consensusScore": consensusScore,
      'status': 'closed',
    }); // end
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Leaderboard
  /// ***********************************************************************
  /// ***********************************************************************

  Future<void> addToLeaderboard(gameMap) async {
    // set data to be saved
    Map<String, dynamic> leaderboardInfo = {};
    leaderboardInfo['userID'] = gameMap['userID'];
    leaderboardInfo['gameMode'] = gameMap['gameMode'];
    leaderboardInfo['gameRulesID'] = gameMap['gameRulesID'];
    leaderboardInfo['score'] = gameMap['playerScores'][gameMap['userID']];
    leaderboardInfo['gameID'] = gameMap['id'];
    leaderboardInfo['ipfsUrl'] = gameMap['ipfsUrl'];
    leaderboardInfo['id'] = createUUID();
    leaderboardInfo['leaderboardStatus'] = 'pending';
    leaderboardInfo['dateUpdated'] = DateTime.now();
    leaderboardInfo['playerNickname'] = gameMap['playerNicknames'][gameMap['userID']];

    // save data to firebase
    await FirebaseFirestore.instance
        .collection('leaderboard')
        .doc(leaderboardInfo['id'])
        .set(leaderboardInfo);
  }

  Future<Map> getLeaderboard({required String gameID}) async {
    Map result = {};
    final judgeRecordsQuery = await FirebaseFirestore.instance
        .collection('leaderboard')
        .where('gameID', isEqualTo: gameID)
        .get();

    if (judgeRecordsQuery.docs.isNotEmpty) {
      result = judgeRecordsQuery.docs.first.data();
    }

    return result;
  }

  Future<Map> getLeaderboardByUserID({required String userID}) async {
    Map result = {};
    final userLeaderboardQuery = await FirebaseFirestore.instance
        .collection('leaderboard')
        .where('userID', isEqualTo: userID)
        .orderBy('dateUpdated', descending: true)
        .get();

    if (userLeaderboardQuery.docs.isNotEmpty) {
      result = userLeaderboardQuery.docs.first.data();
    }

    return result;
  }

  Stream<QuerySnapshot> getLeaderboardByGameRulesStream(String gameRulesID) {
    final Stream<QuerySnapshot> leaderboardStream = FirebaseFirestore.instance
        .collection('leaderboard')
        .where('gameRulesID', isEqualTo: gameRulesID)
        .orderBy('score', descending: true)
        .snapshots();

    var result;
    result = leaderboardStream;
    return result;
  }

  void updateLeaderboard({required GameModel2 gameInfo, required GameModel2Extras gameInfoExtras, required leaderboardID}) async {
    /// Update for this user
    DocumentReference updateMatchForThisUser = FirebaseFirestore.instance
        .collection('leaderboard')
        .doc(leaderboardID);

    updateMatchForThisUser.update({
      "score": gameInfo.playerScores[gameInfoExtras.playerOneUserID],
      'dateUpdated': DateTime.now(),
      'leaderboardStatus': 'closed',
    });
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Other
  /// ***********************************************************************
  /// ***********************************************************************

  /// Obtain game mode details
  Future<Map> fetchGameModeDetails() async {
    final levelDetailsQuery = await FirebaseFirestore.instance
        .collection('gameModes')
        .where('gameMode', isEqualTo: 'matches')
        .get();

    var result = levelDetailsQuery.docs.first.data();
    return result;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Player Records: Get Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Obtain scores for 60 second match
  Future<Map> fetchPlayerRecordsByGameRules({userID, gameRulesID}) async {
    Map result = {};

    final playerRecordsQuery = await FirebaseFirestore.instance
        .collection('playerRecords')
        .doc(userID)
        .collection('byGameRules')
        .where('gameRulesID', isEqualTo: gameRulesID)
        .get();

    if (playerRecordsQuery.docs.isNotEmpty) {
      result = playerRecordsQuery.docs.first.data();
    }

    return result;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Player Records: Save Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Saves their scores to player records collection
  void savePlayerRecordsScore({required GameModel2 gameInfo, required GameModel2Extras gameInfoExtras}) async {
    // Extract required data from gameInfo
    String playerOneUserID = gameInfoExtras.playerOneUserID;
    int score = gameInfo.playerScores[playerOneUserID];
    String gameID = gameInfo.id;
    String movementID = gameInfo.movement['id'];
    Map movementInfo = gameInfo.movement;
    String gameRulesID = gameInfo.gameRules['id'];
    Map gameRulesInfo = gameInfo.gameRules;
    int reps = gameInfo.playerSubScores[playerOneUserID]['reps'];

    List scoreMapToSave = [];
    List scoresArrayToSave = [];
    List repsArrayToSave = [];
    int personalRecord;
    int personalRecordReps;

    /// Create map containing an individual games score
    Map scoreMap = {
      'gameID': gameID,
      'dateTime': DateTime.now(),
      'score': score,
      'reps': reps,
    };

    /// obtain player record collection and locate the specific document
    final userPlayerRecordQuery = await FirebaseFirestore.instance
        .collection('playerRecords')
        .doc(playerOneUserID)
        .collection('byGameRules')
        .where('gameRulesID', isEqualTo: gameRulesID)
        .get();

    /// reference for updating this document
    // what if it doesn't exist yet? what happens? how do I make one?
    DocumentReference updatePlayerRecordsReference = FirebaseFirestore.instance
        .collection('playerRecords')
        .doc(playerOneUserID)
        .collection('byGameRules')
        .doc(gameRulesID);

    /// if nothing returned, then record doesn't exist yet. So create it
    if (userPlayerRecordQuery.docs.isEmpty) {
      scoreMapToSave.add(scoreMap);
      scoresArrayToSave = [score];
      personalRecord = score;
      repsArrayToSave = [reps];

      // create document with one score so far
      await updatePlayerRecordsReference.set({
        "movementID": movementID,
        "movement": movementInfo,
        "gameRulesID": gameRulesID,
        "gameRules": gameRulesInfo,
        "scores": scoreMapToSave,
        "scoresArray": scoresArrayToSave,
        "personalRecord": personalRecord,
        "repsArray": repsArrayToSave,
      });
    } else {
      /// Get the existing data so we can append to it
      // there should only be one result so set result to this document
      var result = userPlayerRecordQuery.docs.first.data();

      // obtain existing scores so we can add to it later
      if (result['scores'] != null) {
        scoreMapToSave = result['scores'];
      }

      // obtain existing scoresArray so we can add to it later
      if (result['scoresArray'] != null) {
        scoresArrayToSave = result['scoresArray'];
      }

      // obtain existing repsArray so we can add to it later
      if (result['repsArray'] != null) {
        repsArrayToSave = result['repsArray'];
      }

      // obtain existing personal record for TOTAL POINTS
      if (result['personalRecord'] != null) {
        personalRecord = result['personalRecord'];

        // set new personal record
        if (GameService.isThisANewPersonalRecord(newScore: score, existingScore: personalRecord)) {
          personalRecord = score;
        }
      } else {
        // no personal record exists yet, so set one
        personalRecord = score;
      }

      // obtain existing personal record for TOTAL REPS
      if (result['personalRecordReps'] != null) {
        personalRecordReps = result['personalRecordReps'];

        // set new personal record
        if (GameService.isThisANewPersonalRecord(newScore: reps, existingScore: personalRecordReps)) {
          personalRecordReps = reps;
        }
      } else {
        // no personal record exists yet, so set one
        personalRecordReps = reps;
      }

      // append our score data to this existing map of data
      scoreMapToSave.add(scoreMap);
      scoresArrayToSave.add(score);
      repsArrayToSave.add(reps);

      // update document
      await updatePlayerRecordsReference.update({
        "scores": scoreMapToSave,
        "scoresArray": scoresArrayToSave,
        "personalRecord": personalRecord,
        'personalRecordReps': personalRecordReps,
        "repsArray": repsArrayToSave,
      });
    }
  }

  void updateWinLossTieRecord(userID, gameRulesID, newWinLossTieRecord) async {
    /// reference for updating this document
    // what if it doesn't exist yet? SetOptions(merge: true) handles this case
    DocumentReference updatePlayerRecordsReference = FirebaseFirestore.instance
        .collection('playerRecords')
        .doc(userID)
        .collection('byGameRules')
        .doc(gameRulesID);

    // update document
    await updatePlayerRecordsReference.set({
      "winLossTieRecord": newWinLossTieRecord,
    },
        SetOptions(merge:true));

    //set(data, SetOptions(merge: true))
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Videos: Get Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get videos
  Stream<QuerySnapshot> fetchVideosByID(String videoName) {
    return FirebaseFirestore.instance
        .collection('videos')
        .where('videoName', isEqualTo: videoName)
        .snapshots();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Videos: Save Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// After downloadURL is generated this method writes to that URL to the relevant document
  Future<void> saveVideoURLtoVideoCollection(String? videoName, String downloadUrl) async {
    await FirebaseFirestore.instance.collection('videos').doc(videoName).set({
      'videoUrl': downloadUrl,
      'finishedProcessing': true,
    }, SetOptions(merge: true));
  }

  Future<void> uploadVideo(videoName, videoFile) async {
    await FirebaseFirestore.instance.collection('videos').doc(videoName).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        print('Document exists in the database');
        final data = ds.data();
        final uploadUrL = (data as dynamic)['uploadUrl'];
        print(uploadUrL);
        var video = VideoModel(uploadUrl: uploadUrL);
        uploadFileBackground(videoName, videoFile.path, video.uploadUrl);
      } else {
        print('Document does not exist');
      }
    });
  }

  Future<void> fetchVideoURLandUpdateMatches(gameMode, userID,) async {
    /// Fetch video collection documents for this user, or their opponent, who have their video background uploaded
    /// but not saved to both players' match or level document
    final query = await FirebaseFirestore.instance.collection('videos')
        .where('finishedProcessing',isEqualTo: false)
        .where('gameMode',isEqualTo: gameMode)
        .where('players', arrayContains: userID)
        .where('uploadComplete',isEqualTo: true).get();

    if (query.docs.isNotEmpty) {
      var doc = query.docs.first.data();

      String videoURL = await FirebaseStorage.instance.ref('user_videos/${doc['videoName']}.mp4').getDownloadURL();
      String gameMode = doc['gameMode'];
      String groupID = doc['groupID'];
      String gameID = doc['gameID'];
      String userID = doc['userID'];
      String videoName = doc['videoName'];

      /// For this user: Saves videoURL to matches collection
      //await updateLevelOrMatchWithVideoURL(gameMode, groupID, gameID, userID, userID, videoURL);
      await updateMatchWithVideoURLFlat(gameMode, groupID, gameID, userID, userID, videoURL);

      /// Saves the videoURL to videos collection and set finishedProcessing to true
      await saveVideoURLtoVideoCollection(videoName, videoURL);
    }
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Firebase Storage
  /// ***********************************************************************
  /// ***********************************************************************

  Future<void> saveFoodPictureToStorage(String picLocation, File imageFile) async {
    await FirebaseStorage.instance.ref(picLocation).putFile(imageFile);
  }

  Future<String> fetchFoodPicture(String picLocation) async {
    return await FirebaseStorage.instance.ref(picLocation).getDownloadURL();
  }

  Future <void> updateMatchActivityTrackerField(Map gameMap) async{

    DateTime timeNow = DateTime.now();
    DateTime dateForMatchActivityMapUpdate = DateTime(timeNow.year,timeNow.month,timeNow.day);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    String dateForMatchActivityMapUpdateString = formatter.format(dateForMatchActivityMapUpdate);



    String userID = gameMap['userID'];
    String opponentID = gameMap['opponentPlayer']['userID'];

    ///Update current user match document
    await FirebaseFirestore.instance
        .collection('matches')
        .doc(gameMap['groupID'])
        .collection(userID)
        .doc(gameMap['id'])
        .update({
      'matchActivityTracker.$userID.$dateForMatchActivityMapUpdateString.nutritionImagePosted': true
    });

    ///Update opponent user match document
    await FirebaseFirestore.instance
        .collection('matches')
        .doc(gameMap['groupID'])
        .collection(opponentID)
        .doc(gameMap['id'])
        .update({
      'matchActivityTracker.$userID.$dateForMatchActivityMapUpdateString.nutritionImagePosted': true
    });

  }

} // end database service class

class VideoDatabaseService {

  ///Records upload time.
  static saveVideoUploadStartTime(VideoModel video) async {
    await FirebaseFirestore.instance
        .collection('videos')
        .doc(video.videoName)
        .set({
      'uploadedAt': video.uploadedAt,
      'videoName': video.videoName,
    },SetOptions(merge: true));
  }

  /// After downloadURL is generated this method writes to that URL to the relevant document
  static saveDownloadURL(String? videoName, String downloadUrl) async {
    var complete1 = await FirebaseFirestore.instance.collection('videos').doc(videoName).set({
      'videoUrl': downloadUrl,
      'finishedProcessing': true,
    }, SetOptions(merge: true));
  }

  /// Creates the initial record for the video in the video collection, pre-upload.
  static createNewVideoCollectionRecord(String videoName, String rawVideoPath, String gameID, String userID, String gameMode, String groupID) async {
    await FirebaseFirestore.instance.collection('videos').doc(videoName).set({
      'finishedProcessing': false,
      "datetimeUrlUploadCreation": DateTime.now(),
      'videoName': videoName,
      'rawVideoPath': rawVideoPath,
      'userID': userID,
      'gameID': gameID,
      'gameMode': gameMode,
      'groupID': groupID,
      "players": [userID],
    });
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Generate Device Tokens for Messaging after video upload
  /// ***********************************************************************
  /// ***********************************************************************

  /// Methods to create and save user tokens needed for messaging
  Future<void> saveTokenToDatabase(String token) async {
    // Assume user is logged in for this example
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
      'tokens': FieldValue.arrayUnion([token]),
    });
  }

  Future<String> generateUserToken() async {
    // Get the token each time the application loads
    String? token = await FirebaseMessaging.instance.getToken();

    // Save the initial token to the database
    await saveTokenToDatabase(token!);

    return token;

  }
}