class GameModel2Extras {
  GameModel2Extras({
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
    this.playerOneUserID = '',
    this.playerTwoUserID = '',
    this.playerOneRecords = const {},
  });

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
  Map<dynamic, dynamic> playerOneRecords;

  String title;
  String playerOneUserID; // this player
  String playerTwoUserID; // opponent user ID
}
