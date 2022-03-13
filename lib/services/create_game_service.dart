import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/constants.dart' as constants;
import 'package:intl/intl.dart';
import 'package:dojo_app/globals.dart' as globals;


class CreateGameService {
  CreateGameService() {
    // constructor
  }

  // Instantiate general databaseServices object that contains methods to CRUD on firebase
  DatabaseServices databaseServices = DatabaseServices();

  late String _playerOne = globals.dojoUser.uid;

  /// ********************************
  /// Setters and Getter Methods
  /// ********************************

  String get playerOneUserID {
    return _playerOne;
  }

  late String playerOneNickname;

  Future<String> getNickname(userID) async {
    // get default background video to play on level selection
    return await databaseServices.fetchNickname(userID: userID);
  }

  Future<Map> getUserInfo(userID) async {
    // get default background video to play on level selection
    return await databaseServices.fetchUserInfo(userID: userID);
  }

  Future<void>createKingOfTheHillGame({required String gameMode, required String gameRulesID}) async {
    /// Fetch both players info
    Map playerOneUserInfo = await getUserInfo(_playerOne);

    /// Set player 1 data
    String player1 = _playerOne;
    String playerNickname1 = playerOneUserInfo['Nickname'];
    String playerAvatar1 = 'images/avatar-blank.png';
    String userID1 = player1;

    /// Set general game data
    // gameMode = gameMode;
    // gameRulesID = 'DLdsgABrmYpoLWw2x2C0';
    String id = createUUID();
    String gameStatus = constants.cGameStatusOpen;
    Map<String, String> playerGameOutcomes = {player1: 'open'};
    int duration = 60;

    /// Set dates
    DateTime dateCreated = DateTime.now();
    DateTime dateUpdated = DateTime.now();
    Map dates = {};

    /// Calculate match expiration date
    DateTime today = DateTime.now();
    DateTime matchDateTimeExpiration = DateTime(today.year, today.month, today.day - (today.weekday - 7),23);

    /// Calculate start date
    DateTime dateStart = DateTime(today.year, today.month, today.day - (today.weekday - 2)); //Always Tuesday

    /// Set known player data
    Map<String, String> playerAvatars = {player1: playerAvatar1};
    Map<String, String> playerNicknames = {player1: playerNickname1};
    List players = [player1];
    bool paymentReceived = false;
    String ethereumAddress = 'xyz';
    String _gameRulesID = gameRulesID;

    /// Get player discord member IDs
    Map<String, int> playerDiscordMemberIDs = {};
    if (playerOneUserInfo.containsKey('discordMemberID')){
      playerDiscordMemberIDs[playerOneUserID] = playerOneUserInfo['discordMemberID'];
    }

    /// Set game data that starts out as blank
    Map playerNotes = {};
    Map playerVideos = {};
    Map playerScores = {};
    List playerFoodPics = [];
    String ipfsUrl = '';

    /// ********************************
    /// Set game rules and movement
    /// ********************************

    /// Set game Rules
    // TODO: dynamically pull data from game rules document
    Map<dynamic, dynamic> gameRules = await databaseServices.gameRules(gameRulesID: gameRulesID);

    /// Set movement data
    // TODO: dynamically pull data from movement document
    Map<String, dynamic> movement = {
      "description":
      "Traditional pushups are beneficial for building upper body strength. They work the triceps, pectoral muscles, and shoulders. When done with proper form, they can also strengthen the lower back and core by engaging (pulling in) the abdominal muscles. Pushups are a fast and effective exercise for building strength.",
      "id": "ec86c6d1-3a25-4435-9dc3-8fbf7bb17834",
      "title": "Traditional Pushup",
      "type": "pushup",
      "videoTutorial":
      "https://firebasestorage.googleapis.com/v0/b/dojo-app-prod.appspot.com/o/assets_app%2Fvideos%2Ftutorials%2FTutorial-Traditional-Pushup-Van-1.mp4?alt=media&token=f320e6fd-a364-4b56-9225-c606cf18fe74",
      "videoTutorialShort":
      "https://firebasestorage.googleapis.com/v0/b/dojo-app-prod.appspot.com/o/assets_app%2Fvideos%2Ftutorials%2Fpushup_with_cat4.gif?alt=media&token=88ecbee1-8409-4118-9e77-29a85028f5a7"
    };

    /// ********************************
    /// Create maps for both players
    /// ********************************

    /// Setup map for player 1
    Map<String, dynamic> matchPlayerMap1 = {
      'dateCreated': dateCreated,
      'dateUpdated': dateUpdated,
      'dateStart': dateStart,
      'dates': dates,
      'dateMatchExpiration': matchDateTimeExpiration,
      'duration': duration,
      'gameMode': gameMode,
      'gameRules': gameRules,
      'gameStatus': gameStatus,
      'id': id,
      'ipfsUrl': ipfsUrl,
      'movement': movement,
      'playerAvatars': playerAvatars,
      'playerGameOutcomes': playerGameOutcomes,
      'playerNicknames': playerNicknames,
      'playerNotes': playerNotes,
      'playerVideos': playerVideos,
      'playerScores': playerScores,
      'playerFoodPics': playerFoodPics,
      'playerDiscordMemberIDs': playerDiscordMemberIDs,
      'players': players,
      'userID': userID1,
      'paymentReceived': paymentReceived,
      'ethereumAddress': ethereumAddress,
      'gameRulesID': _gameRulesID,
    };

    /// ***************************************
    /// Create match in MatchesFlat collection
    /// **************************************

    /// Remove userID from map
    Map<String, dynamic> matchPlayerMapForPlayerOne = Map.from(matchPlayerMap1);

    /// Save match for player1 and player2 as one document to matchesAll collection
    await databaseServices.createGame(matchPlayerMapForPlayerOne);
  }
}
