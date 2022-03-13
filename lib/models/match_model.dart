class MatchModel {
  MatchModel({
    this.category = 'fitness',
    required this.dateCreated,
    required this.dateUpdated,
    required this.duration,
    required this.gameMode,
    required this.gameRules,
    required this.gameStatus,
    required this.groupID,
    required this.id,
    required this.movement,
    required this.playerAvatars,
    required this.playerGameOutcomes,
    required this.playerNicknames,
    this.playerNotes = const {},
    this.playerVideos = const {},
    required this.players,
    required this.userID,
  });

  String category;
  DateTime dateCreated;
  DateTime dateUpdated;
  int duration;
  String gameMode;
  Map<String, dynamic> gameRules;
  String gameStatus;
  String groupID;
  String id;
  Map<String, dynamic> movement;
  Map playerAvatars;
  Map<String, String> playerGameOutcomes;
  Map<String, String> playerNicknames;
  Map playerNotes;
  Map playerVideos;
  List players;
  String userID;
}