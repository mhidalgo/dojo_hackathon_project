import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/constants.dart' as constants;
import 'package:intl/intl.dart';


class CreateMatchBloc {
  CreateMatchBloc() {
    // constructor
  }

  // Instantiate general databaseServices object that contains methods to CRUD on firebase
  DatabaseServices databaseServices = DatabaseServices();

  late String _playerOne = 'AI22rzMxuphgmK5Zr8lVGht3O3D3';
  late String _playerTwo = 'eKv2KuKDJNNba7OUy1SNo3ilfiq2';

  /// Stream for the view so it can display list of level cards to user
  Stream<QuerySnapshot> get users => _users;
  //Stream<QuerySnapshot<Map<String, dynamic>>> _users = FirebaseFirestore.instance.collection('users').snapshots();
  Stream<QuerySnapshot> _users = FirebaseFirestore.instance.collection('users').snapshots();

  /// ********************************
  /// Setters and Getter Methods
  /// ********************************
  ///
  String get playerOneUserID {
    return _playerOne;
  }

  String get playerTwoUserID {
    return _playerTwo;
  }

  /// Create match screen populates this value after every time a new item selection is made
  set setPlayerOne(String playerOne){
    _playerOne = playerOne;
    printBig('playerOne', '$_playerOne');
  }

  /// Create match screen populates this value after every time a new item selection is made
  set setPlayerTwo(String playerTwo){
    _playerTwo = playerTwo;
    printBig('playerTwo', '$_playerTwo');
  }

  late String playerOneNickname;
  late String playerTwoNickname;

  Future<String> getNickname(userID) async {
    // get default background video to play on level selection
    return await databaseServices.fetchNickname(userID: userID);
  }

  Future<Map> getUserInfo(userID) async {
    // get default background video to play on level selection
    return await databaseServices.fetchUserInfo(userID: userID);
  }

  /// Iterate through snapshot to find the nickname
  /*void getNickname() {
    users.forEach((field) {
      field.docs.asMap().forEach((index, data) {
        printBig('iterate', 'true');
        if (field.docs[index]['User_ID'] == _playerOne) {
          printBig('playerOneNickname', '${field.docs[index]['Nickname']}');
          playerOneNickname = field.docs[index]['Nickname'];
        } else {
          printBig('FALSE playerOneNickname', '${field.docs[index]['Nickname']}');
        }
      });
    });
  }*/


  Future<void>createMatchForMV() async {
    /*
    9GOD (Assibey): 9pkqB0XQ6HNiRnw8qz2FjccbvGi2
    RKittens (Ryan Kelly): CA3lGuhgoFgwmKWyyrdBBLJJWyC2
    Stickman (Craig): JPOCeH9fPJaXPcRnVwe4A2McJBq1
    Shazam (Chirag): NQbUkUsyUvgM7jDEZqNQpuqcxpS2
    StickMom (Debbie): OUbllyr5PzfsYzFlXxyrSvjF8hm1
    Digital Ruffian (Diggy): ZjlXsnHGEBcCcPKGkbUxdEIGcR42
    Ben Yeo: frh84a5eszXQNG3aPLS31hQGzgv2
    Jbnguyen (Jamie): 6n5A87DnNMNdj0qOtjemKS5CYn43
    Vanielson prod: IaNoVdiaMtWiiyD7HFlRf5MqqSE3
    Marvin prod: RRmF9OaRW1Ue6kHtczyILqq9Fyc2
    Vanielson dev: AI22rzMxuphgmK5Zr8lVGht3O3D3
    Marvin dev: eKv2KuKDJNNba7OUy1SNo3ilfiq2
    Aditya (Adi): GIBZhADXUDVzQNHwN8rI6ihukwv1
    Matt (Matt): QnpMSlcLjvYFwS1M27Ov7N9X6Vw1
    Alex: JfjUkOFqoJMesjPogAV8PZaUlfN2;
    */

    /// Fetch both players info
    Map playerOneUserInfo = await getUserInfo(_playerOne);
    Map playerTwoUserInfo = await getUserInfo(_playerTwo);

    /// Set player 1 data
    String player1 = _playerOne;
    String playerNickname1 = playerOneUserInfo['Nickname'];
    String playerAvatar1 = 'images/avatar-blank.png';
    String userID1 = player1;

    /// Set player 2 data
    String player2 = _playerTwo;
    String playerNickname2 = playerTwoUserInfo['Nickname'];
    String userID2 = player2;
    String playerAvatar2 = 'images/avatar-blank.png';

    /// Set general game data
    String gameMode = 'matches';
    String groupID = 'NUcZNP5oto6XZP7oictP';
    String id = createUUID();
    String gameStatus = constants.cGameStatusOpen;
    Map<String, String> playerGameOutcomes = {player1: 'open', player2: 'open'};
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
    Map<String, String> playerAvatars = {player1: playerAvatar1, player2: playerAvatar2};
    Map<String, String> playerNicknames = {player1: playerNickname1, player2: playerNickname2};
    List players = [player1, player2];

    /// Get player discord member IDs
    Map<String, int> playerDiscordMemberIDs = {};
    if (playerOneUserInfo.containsKey('discordMemberID')){
      playerDiscordMemberIDs[playerOneUserID] = playerOneUserInfo['discordMemberID'];
    }
    if (playerTwoUserInfo.containsKey('discordMemberID')){
      playerDiscordMemberIDs[playerTwoUserID] = playerTwoUserInfo['discordMemberID'];
    }

    printBig('playerDiscordMemberIds', '$playerDiscordMemberIDs');

    /// Set game data that starts out as blank
    Map playerNotes = {};
    Map playerVideos = {};
    Map playerScores = {};
    List playerFoodPics = [];

    /// ********************************
    /// Set game rules and movement
    /// ********************************

    /// Set game Rules
    // TODO: dynamically pull data from game rules document
    Map<String, dynamic> gameRules = {
      "description": "Perform as many pushups within a time limit",
      "duration": 60,
      "id": "ZlYBWj4jbLddLJEDZbLK",
      "maxPlayers": 2,
      "title": "Pushup Sprint"
    };

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
    /// Match Activity Tracker Data
    /// ********************************


    //Format DateTime object to a Date String with following format 'yyyy-MM-dd'
    ///Match Activity tracker calculations
    DateTime firstMatchDate = DateTime(today.year, today.month, today.day - (today.weekday - 2)); //Always Tuesday
    DateTime secondMatchDate = DateTime(today.year, today.month, today.day - (today.weekday - 3));
    DateTime thirdMatchDate = DateTime(today.year, today.month, today.day - (today.weekday - 4));
    DateTime fourthMatchDate = DateTime(today.year, today.month, today.day - (today.weekday - 5));
    DateTime fifthMatchDate = DateTime(today.year, today.month, today.day - (today.weekday - 6));
    DateTime sixthMatchDate = DateTime(today.year, today.month, today.day - (today.weekday - 7));

    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    //Dates formatted to 2022-MM-dd
    String firstMatchDateString = formatter.format(firstMatchDate);
    String secondMatchDateString = formatter.format(secondMatchDate);
    String thirdMatchDateString = formatter.format(thirdMatchDate);
    String fourthMatchDateString  = formatter.format(fourthMatchDate);
    String fifthMatchDateString  = formatter.format(fifthMatchDate);
    String sixthMatchDateString  = formatter.format(sixthMatchDate);


    //This determines whether to use the extra day
    DateTime tenAmTimeCheckDate = DateTime(today.year,today.month,today.day,10,0,0);

    bool nutritionImagePosted = false;

    Map matchActivityTracker = {

      userID1: {
        firstMatchDateString: {
          "nutritionImagePosted": nutritionImagePosted
        },
        secondMatchDateString: {
          "nutritionImagePosted": nutritionImagePosted
        },
        thirdMatchDateString: {
          "nutritionImagePosted": nutritionImagePosted
        },
        fourthMatchDateString: {
          "nutritionImagePosted": nutritionImagePosted
        },
        fifthMatchDateString: {
          "nutritionImagePosted": nutritionImagePosted
        },
        sixthMatchDateString: {
          "nutritionImagePosted": nutritionImagePosted
        },
      },
      userID2: {
        firstMatchDateString: {
          "nutritionImagePosted": nutritionImagePosted
        },
        secondMatchDateString: {
          "nutritionImagePosted": nutritionImagePosted
        },
        thirdMatchDateString: {
          "nutritionImagePosted": nutritionImagePosted
        },
        fourthMatchDateString: {
          "nutritionImagePosted": nutritionImagePosted
        },
        fifthMatchDateString: {
          "nutritionImagePosted": nutritionImagePosted
        },
        sixthMatchDateString: {
          "nutritionImagePosted": nutritionImagePosted
        },
      }

    };



    /// Create form judge questions
    Map qJudgeForm1 = {
      "answer": 0,
      "answerOptions": [1,2,3],
      "question": "On the pushup down position, elbows should be 90 degrees.",
      "questionSubType": "happy to sad emoji likert",
      "questionType": "multiple choice",
      "id": "cc3a327d-26ea-40ae-8a60-d3fc50f35751",
      "shortDescription": "90 degree elbows",
    };

    Map qJudgeForm2 = {
      "answer": 0,
      "answerOptions": [1,2,3],
      "question": "On the pushup up position, arms should be fully extended.",
      "questionSubType": "happy to sad emoji likert",
      "questionType": "multiple choice",
      "id": "cc3a327d-26ea-40ae-8a60-d3fc50f35752",
      "shortDescription": "Arm extension"
    };

    Map qJudgeForm3 = {
      "answer": 0,
      "answerOptions": [1,2,3],
      "question": "Hand floor placement should be slightly further than shoulder width apart.",
      "questionSubType": "happy to sad emoji likert",
      "questionType": "multiple choice",
      "id": "cc3a327d-26ea-40ae-8a60-d3fc50f35753",
      "shortDescription": "Hand placement"
    };

    /// Prepare questions Map
    // prepare map of form questions
    List qJudgeFormAll = [qJudgeForm1, qJudgeForm2, qJudgeForm3];

    // set form questions for both players
    Map qJudgeFormBothPlayers = {
      player1:qJudgeFormAll,
      player2:qJudgeFormAll};

    // set Map that will be saved to firebase
    Map questions = {"form": qJudgeFormBothPlayers};

    /// Create map for judging
    Map judging = {
      "status": constants.cGameStatusSecondaryJudgeOpen,
      "userID": "",
      "nickname": "",
    };

    /// ********************************
    /// Different types of points you can earn
    /// ********************************

    /// Create map for playerSubScores
    Map<String, int> playerOneSubScores = {
      "reps": 0,
      "form": 0,
      "sleep": 0,
      "nutrition": 0,
    };

    Map<String, int> playerTwoSubScores = {
      "reps": 0,
      "form": 0,
      "sleep": 0,
      "nutrition": 0,
    };

    Map playerSubScores = {
      player1:playerOneSubScores,
      player2: playerTwoSubScores
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
      'groupID': groupID,
      'id': id,
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
      'questions': questions,
      'judging': judging,
      'playerSubScores': playerSubScores,
      'matchActivityTracker':matchActivityTracker
    };

    /// Setup map for player 2
    Map<String, dynamic> matchPlayerMap2 = Map.from(matchPlayerMap1);
    matchPlayerMap2['userID'] = userID2;

    /// ********************************
    /// DB Calls to create match documents
    /// ********************************

    /// Save match for player1
    await databaseServices.createMatchForMV(matchPlayerMap1);

    /// Save match for player2
    await databaseServices.createMatchForMV(matchPlayerMap2);

    /// ********************************
    /// Create match in MatchesFlat collection
    /// ********************************

    /// Remove userID from map
    Map<String, dynamic> matchPlayerMapForPlayerOneAndTwo = Map.from(matchPlayerMap1);
    matchPlayerMapForPlayerOneAndTwo.remove('userID');

    /// Save match for player1 and player2 as one document to matchesAll collection
    await databaseServices.createMatchForMVFlat(matchPlayerMapForPlayerOneAndTwo);
  }
}
