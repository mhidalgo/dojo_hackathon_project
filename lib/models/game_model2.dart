class GameModel2 {
  GameModel2({
    this.gameMode = '0',
    this.groupID = '0',
    this.id = '0',
    this.gameID = '0',
    this.gameStatus = '0',
    this.players = const ['0'],
    this.playerNicknames = const {'Empty': '0'},
    this.playerScores = const {},
    this.playerVideos = const {},
    this.playerGameOutcomes = const {},
    this.level = 0,
    this.movement = const {'Empty': '0'},
    this.playerNotes = const {'Empty': '0'},
    this.gameRules = const {},
    this.questions = const {},
    this.judging = const {},
    this.playerSubScores = const {},
    this.dates = const {},
    this.userID = '',
  });

  String gameMode;
  String groupID; // levelGroupID, matchGroupID
  String id; // levelID, matchID
  String gameStatus;
  String gameID; // temporary gameID
  String userID;

  List<dynamic> players;
  Map<String, dynamic> playerNicknames;
  Map<String, dynamic> playerScores;
  Map<String, dynamic> playerVideos;
  Map<String, dynamic> playerNotes;
  Map<String, dynamic> playerGameOutcomes;
  Map<String, dynamic> movement;
  Map<String, dynamic> gameRules;
  Map<dynamic, dynamic> questions;
  Map<dynamic, dynamic> judging;
  Map<dynamic, dynamic> playerSubScores;
  Map<dynamic, dynamic> dates;
  int level;
}
