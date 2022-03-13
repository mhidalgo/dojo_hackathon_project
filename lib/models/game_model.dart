class GameModel {
  GameModel({
    this.gameMode = '0',
    this.groupID = '0',
    this.id = '0',
    this.gameID = '0',
    this.gameStatus = '0',
    this.opponentVideoAvailable = false,
    this.gameDuration = 60,
    this.player1Score = '0',
    this.player2Score = '0',
    this.player1Nickname = '',
    this.player2Nickname = '',
    this.player1ID = '0',
    this.player2ID = '0',
    this.player1VideoURL = '0',
    this.player2VideoURL = '0',
    this.title = '',
    this.currentUserID = '',
    this.opponentUserID = '',
    this.players = const ['0'],
    this.playerNicknames = const {'Empty': '0'},
    this.playerScores = const {},
    this.playerVideos = const {},
    this.playerGameOutcomes = const {},
    this.level = 0,
    this.movement = const {'Empty': '0'},
    this.playerNotes = const {'Empty': '0'},
    this.gameRules = const {},
    this.playerOneRecords = const {},
    this.questions = const {},
    this.judging = const {},
  });

  String gameMode;
  String groupID; // levelGroupID, matchGroupID
  String id; // levelID, matchID
  String gameStatus;
  String gameID; // temporary gameID
  bool opponentVideoAvailable;

  int gameDuration;
  String player1Score;
  String player2Score;
  String player1Nickname;
  String player2Nickname;
  String player1ID;
  String player2ID;
  String player1VideoURL;
  String player2VideoURL;

  String title;
  String currentUserID;
  String opponentUserID;

  List<dynamic> players;
  Map<String, dynamic> playerNicknames;
  Map<String, dynamic> playerScores;
  Map<String, dynamic> playerVideos;
  Map<String, dynamic> playerNotes;
  Map<String, dynamic> playerGameOutcomes;
  Map<String, dynamic> movement;
  Map<String, dynamic> gameRules;
  Map<dynamic, dynamic> playerOneRecords;
  Map<dynamic, dynamic> questions;
  Map<dynamic, dynamic> judging;
  int level;
}
