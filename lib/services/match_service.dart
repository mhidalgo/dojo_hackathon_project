import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/constants.dart' as constants;
import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/models/game_model2.dart';
import 'package:dojo_app/models/game_model2_extras.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/widgets/notification_match_expiration_timer.dart';
import 'package:dojo_app/widgets/notification_match.dart';
import 'dart:io';

import 'helper_functions.dart';

class MatchService {
  // Initialize DB object with methods to call DB
  DatabaseServices databaseServices = DatabaseServices();

  /// Constructor
  MatchService() {
    //
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Create Game Objects
  /// ***********************************************************************
  /// ***********************************************************************

  GameModel2 createGameObject(gameMap){
    // Takes a parameter of gameMap, which contains a replica of a match document
    // Create game object with required data so we can update match document
    // with data from an existing match.
    // Below,the ternary operator because those fields may be null in some cases
    // since they aren't used in every type of match
    GameModel2 _gameInfo = GameModel2(
      gameMode: gameMap['gameMode'],
      id: gameMap['id'],
      gameStatus: gameMap['gameStatus'],
      playerScores: gameMap['playerScores'],
      playerGameOutcomes: gameMap['playerGameOutcomes'],
      gameRules: gameMap['gameRules'],
      players: gameMap['players'],
      playerNicknames: gameMap['playerNicknames'],
      playerVideos: gameMap['playerVideos'],
      playerNotes: gameMap['playerNotes'],
      movement: gameMap['movement'],
      questions: (gameMap['questions'] != null) ? gameMap['questions'] : {},
      judging: (gameMap['judging'] != null) ? gameMap['judging'] : {},
      level: (gameMap['level'] != null) ? gameMap['level'] : 0,
      playerSubScores: (gameMap['playerSubScores'] != null) ? gameMap['playerSubScores'] : {},
      dates: gameMap['dates'],
      userID: gameMap['userID'],
    );

    return _gameInfo;
  }

  GameModel2Extras createGameExtrasObject(gameMap, playerOneUserID){
    // Create game object with required data so we can update match documents
    GameModel2Extras _gameInfoExtras = GameModel2Extras(
      playerOneUserID: playerOneUserID, // this player
      opponentVideoAvailable: false,
      title: gameMap['gameRules']['title'] as String,
      gameDuration: gameMap['gameRules']['duration'] as int,
    );

    return _gameInfoExtras;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Match Screen Alerts about match status
  /// ***********************************************************************
  /// ***********************************************************************

  /// gets notifications (top of screen banner) that display on game modes or matches screen
  List<Widget> getMatchNotifications(QuerySnapshot matchDetails) {
    List<Widget> notificationWidgetList = [Container()];

    if (matchDetails.docs.isNotEmpty) {
      var details = matchDetails.docs.first.data() as Map<dynamic, dynamic>;
      String matchStatus = getPlayersStatusInAMatch(matchDetails);

      /// Open matches display the countdown to match expiration
      if (details['gameStatus'] == constants.cGameStatusOpen) {
        var matchExpirationDateTime = details['dateMatchExpiration'].toDate();
        notificationWidgetList.add(
          NotificationMatchExpirationTimer(expirationDateTime: matchExpirationDateTime),
        );
        notificationWidgetList.add(SizedBox(height: 4));
      }

      /// This player has played, opponent has NOT played
      if (matchStatus == constants.cGameOpenPlayerOneHasPlayedPlayerTwoHasNotPlayed) {
        notificationWidgetList.add(NotificationMatch(message: 'Waiting for your opponent to play'));
        notificationWidgetList.add(SizedBox(height: 4));
      }

      /// This player has NOT played, opponent has played
      if (matchStatus == constants.cGameOpenPlayerOneHasNotPlayedPlayerTwoHasPlayed) {
        notificationWidgetList.add(NotificationMatch(message: 'Waiting on you to play'));
        notificationWidgetList.add(SizedBox(height: 4));
      }

      /// Game = closed (completed) so let them know results are in
      if (matchStatus == constants.cGameClosedBothPlayersLoseByForfeit ||
          matchStatus == constants.cGameClosedPlayerOneWinsPlayerTwoLoses ||
          matchStatus == constants.cGameClosedPlayerOneLosesPlayerTwoWins ||
          matchStatus == constants.cGameClosedPlayerOneWinsByForfeitPlayerTwoLosesByForfeit ||
          matchStatus == constants.cGameClosedPlayerOneLosesByForfeitPlayerTwoWinsLosesByForfeit ||
          matchStatus == constants.cGameClosedPlayerOneTiesPlayerTwoTies) {
        notificationWidgetList.add(NotificationMatch(message: 'The results are in'));
        notificationWidgetList.add(SizedBox(height: 4));
      }

      /// Game = closed so let them know a new one will be setup soon
      if (matchStatus == constants.cGameClosedBothPlayersLoseByForfeit ||
          matchStatus == constants.cGameClosedPlayerOneWinsPlayerTwoLoses ||
          matchStatus == constants.cGameClosedPlayerOneLosesPlayerTwoWins ||
          matchStatus == constants.cGameClosedPlayerOneWinsByForfeitPlayerTwoLosesByForfeit ||
          matchStatus == constants.cGameClosedPlayerOneLosesByForfeitPlayerTwoWinsLosesByForfeit ||
          matchStatus == constants.cGameClosedPlayerOneTiesPlayerTwoTies) {
        notificationWidgetList.add(NotificationMatch(message: 'The next match will be setup soon'));
        notificationWidgetList.add(SizedBox(height: 4));
      }
    }
    return notificationWidgetList;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Match Expired?
  /// ***********************************************************************
  /// ***********************************************************************

  /// Check whether a match's expiration date has elapsed
  bool isMatchExpired(QuerySnapshot matchDetails) {
    bool isThisMatchExpired = false;
    if (matchDetails.docs.isNotEmpty) {
      var details = matchDetails.docs.first.data() as Map<dynamic, dynamic>;
      if (details['gameStatus'] == constants.cGameStatusOpen) {
        if (details['dateMatchExpiration'].toDate().isBefore(DateTime.now())) {
          isThisMatchExpired = true;
        } else {
          isThisMatchExpired = false;
        }
      }
    }
    return isThisMatchExpired;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Forfeit Match
  /// ***********************************************************************
  /// ***********************************************************************

  Future<void> forfeitMatch(QuerySnapshot matchDetails, String matchStatus, String playerOneUserID) async {
    if (matchDetails.docs.isNotEmpty) {
      var details = matchDetails.docs.first.data() as Map<dynamic, dynamic>;
      details['gameStatus'] = constants.cGameStatusClosed;

      late String thisPlayerGameOutcome;
      late String opponentPlayerGameOutcome;
      late String _playerOneUserID = playerOneUserID; // this player
      late String _playerTwoUserID = getOpponentUserID(details, _playerOneUserID);

      if (matchStatus == constants.cGameOpenBothPlayersHaveNotPlayed) {
        /// Case: Game Open - both players have NOT played yet
        thisPlayerGameOutcome = constants.cPlayerGameOutcomeLoseByForfeit;
        opponentPlayerGameOutcome = constants.cPlayerGameOutcomeLoseByForfeit;
        details['playerGameOutcomes'][_playerOneUserID] = thisPlayerGameOutcome;
        details['playerGameOutcomes'][_playerTwoUserID] = opponentPlayerGameOutcome;
        details['playerScores'][_playerOneUserID] = 0;
        details['playerScores'][_playerTwoUserID] = 0;
      } else if (matchStatus == constants.cGameOpenPlayerOneHasPlayedPlayerTwoHasNotPlayed) {
        /// This player has played so they win by forfeit, but opponent has NOT played and loses by forfeit
        thisPlayerGameOutcome = constants.cPlayerGameOutcomeWinByForfeit;
        opponentPlayerGameOutcome = constants.cPlayerGameOutcomeLoseByForfeit;
        details['playerGameOutcomes'][_playerOneUserID] = constants.cPlayerGameOutcomeWinByForfeit;
        details['playerGameOutcomes'][_playerTwoUserID] = constants.cPlayerGameOutcomeLoseByForfeit;
        details['playerScores'][_playerTwoUserID] = 0;
      } else if (matchStatus == constants.cGameOpenPlayerOneHasNotPlayedPlayerTwoHasPlayed) {
        /// This player has NOT played so they lose by forfeit, but opponent has played and wins by forfeit
        thisPlayerGameOutcome = constants.cPlayerGameOutcomeLoseByForfeit;
        opponentPlayerGameOutcome = constants.cPlayerGameOutcomeWinByForfeit;
        details['playerGameOutcomes'][_playerOneUserID] = constants.cPlayerGameOutcomeLoseByForfeit;
        details['playerGameOutcomes'][_playerTwoUserID] = constants.cPlayerGameOutcomeWinByForfeit;
        details['playerScores'][_playerOneUserID] = 0;
      }

      /// Call db to update match
      await databaseServices.updateForfeitedMatch(details);

      // Update match document in collection matchesAll
      await databaseServices.updateForfeitedMatchFlat(details);

      /// Create new playerGameOutcomeMap to replicate what would be in the DB now
      // doing this so we don't have to call the DB again to get latest playerGameOutcomes
      // instead, we can construct it ourselves here
      Map playerGameOutcomes = {
        _playerOneUserID: thisPlayerGameOutcome,
        _playerTwoUserID: opponentPlayerGameOutcome,
      };

      /// Update win loss record for both players
      updateWinLossRecord(
        playerOneUserID: _playerOneUserID,
        playerTwoUserID: _playerTwoUserID,
        gameRulesId: details['gameRules']['id'],
        playerGameOutcomes: playerGameOutcomes,
      );
    }
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Get Match Status
  /// ***********************************************************************
  /// ***********************************************************************

  /// Determines the status of a match
  /// the result can be used to determine the state of the match
  /// so you can make choices on what to display or what functionality to provide
  /// the varying status of each match can be found in the constants file
  String getPlayersStatusInAMatch(QuerySnapshot matchDetails) {
    String matchStatus = constants.cGameOpenUnhandledCase;

    if (matchDetails.docs.isNotEmpty) {
      var details = matchDetails.docs.first.data() as Map<dynamic, dynamic>;

      /// Extract required variables
      // this player = playerOne, opponent player = playerTwo
      String thisPlayerUserID = details['userID'];
      String opponentPlayerUserID = getOpponentUserID(details, thisPlayerUserID);
      String thisPlayerGameOutcome = details['playerGameOutcomes'][thisPlayerUserID];
      String opponentPlayerGameOutcome = details['playerGameOutcomes'][opponentPlayerUserID];

      /// ***********************************************************************
      /// GameStatus = open
      /// ***********************************************************************

      if (details['gameStatus'] == constants.cGameStatusOpen) {

        /// Case: both players have NOT played yet
        if (thisPlayerGameOutcome == constants.cPlayerGameOutcomeOpen &&
            opponentPlayerGameOutcome == constants.cPlayerGameOutcomeOpen) {
          matchStatus = constants.cGameOpenBothPlayersHaveNotPlayed;

          /// This player played, but opponent has not played
        } else if (thisPlayerGameOutcome == constants.cPlayerGameOutcomePending &&
            opponentPlayerGameOutcome == constants.cPlayerGameOutcomeOpen) {
          matchStatus = constants.cGameOpenPlayerOneHasPlayedPlayerTwoHasNotPlayed;

          /// This player has NOT played, but opponent HAS played
        } else if (thisPlayerGameOutcome == constants.cPlayerGameOutcomeOpen &&
            opponentPlayerGameOutcome == constants.cPlayerGameOutcomePending) {
          matchStatus = constants.cGameOpenPlayerOneHasNotPlayedPlayerTwoHasPlayed;

          /// A case we didn't handle so do this..
        } else {
          matchStatus = constants.cGameOpenUnhandledCase;
        }
      }

      /// ***********************************************************************
      /// GameStatus = closed
      /// ***********************************************************************

      if (details['gameStatus'] == constants.cGameStatusClosed) {

        /// both have forfeited
        if (thisPlayerGameOutcome == constants.cPlayerGameOutcomeLoseByForfeit &&
            opponentPlayerGameOutcome == constants.cPlayerGameOutcomeLoseByForfeit) {
          matchStatus = constants.cGameClosedBothPlayersLoseByForfeit;

          /// this player has won case, opponent loses
        } else if (thisPlayerGameOutcome == constants.cPlayerGameOutcomeWin &&
            opponentPlayerGameOutcome == constants.cPlayerGameOutcomeLose) {
          matchStatus = constants.cGameClosedPlayerOneWinsPlayerTwoLoses;

          /// this player has lost
        } else if (thisPlayerGameOutcome == constants.cPlayerGameOutcomeLose &&
            opponentPlayerGameOutcome == constants.cPlayerGameOutcomeWin) {
          matchStatus = constants.cGameClosedPlayerOneLosesPlayerTwoWins;

          /// this player wins by forfeit
        } else if (thisPlayerGameOutcome == constants.cPlayerGameOutcomeWinByForfeit &&
            opponentPlayerGameOutcome == constants.cPlayerGameOutcomeLoseByForfeit) {
          matchStatus = constants.cGameClosedPlayerOneWinsByForfeitPlayerTwoLosesByForfeit;

          /// this player loses by forfeit
        } else if (thisPlayerGameOutcome == constants.cPlayerGameOutcomeLoseByForfeit &&
            opponentPlayerGameOutcome == constants.cPlayerGameOutcomeWinByForfeit) {
          matchStatus = constants.cGameClosedPlayerOneLosesByForfeitPlayerTwoWinsLosesByForfeit;

          /// both players tied
        } else if (thisPlayerGameOutcome == constants.cPlayerGameOutcomeTie &&
            opponentPlayerGameOutcome == constants.cPlayerGameOutcomeTie) {
          matchStatus = constants.cGameClosedPlayerOneTiesPlayerTwoTies;

          /// we didn't handle a case so do this
        } else {
          matchStatus = constants.cGameClosedUnhandledCase;
        }
      }
    }

    return matchStatus;

  } // end getMatchState2()

  /// Get challenge button status
  // show - required:
  //  - match is open,
  //  - it is game day,
  //  - this player has not played yet

  /// Get sleep or nutrition button status
  // show - required:
  //  - game must be open
  //  - this player has not played yet
  //  - this player did not submit today

  /// ***********************************************************************
  /// ***********************************************************************
  /// Get player personal records
  /// ***********************************************************************
  /// ***********************************************************************

  /// From matches doc, get the scores map and personal record
  // iterate through the map to build a LIST that will be used later by charts
  Future<Map> getPlayerRecords(String gameRulesID, String userID) async {
    Map playerRecords = {}; // {scoresOverTimeList: scoresOverTime, personalRecord: #, winLossTieRecord: '3-3-3'}
    List scoresOverTime = [];
    int personalRecord = 0;
    int personalRecordReps = 0;
    String winLossTieRecord = '0W-0L-0T';

    /// Store player records document as a map
    // var details = matchDetails.docs.first.data() as Map<dynamic, dynamic>;
    Map playerRecordsData = await databaseServices.fetchPlayerRecordsByGameRules(userID: userID, gameRulesID: gameRulesID);

    // TODO: what if there are no player records collection at all? Does this crash?

    /// Store and sort all scores for this gameRulesID
    if (playerRecordsData['scores'] != null) {
      scoresOverTime = playerRecordsData['scores'];

      /// Sort List by date
      scoresOverTime.sort((a, b) {
        var aDate = a['dateTime'].toDate(); //before -> var adate = a.expiry;
        var bDate = b['dateTime'].toDate(); //var bDate = b.expiry;
        return -bDate.compareTo(aDate);
      });
    }

    /// Store personal record for total points
    if (playerRecordsData['personalRecord'] != null) {
      personalRecord = playerRecordsData['personalRecord'];
    }

    /// Store personal record for MAX REPS
    if (playerRecordsData['personalRecordReps'] != null) {
      personalRecordReps = playerRecordsData['personalRecordReps'];
    }

    /// Store win loss tie record
    if (playerRecordsData['winLossTieRecord'] != null) {
      Map tempWinLossTieRecordMap = playerRecordsData['winLossTieRecord'];
      winLossTieRecord =
          '${tempWinLossTieRecordMap['win']}W-${tempWinLossTieRecordMap['loss']}L-${tempWinLossTieRecordMap['tie']}T';
    }

    /// Remove all but the last 6 items in the scores list
    // so that we only display the most 6 recent items
    // so we don't overload the chart with too many data points
    if (scoresOverTime.length > 6) {
      int excessNumberOfItems = scoresOverTime.length - 6;
      scoresOverTime.removeRange(0, excessNumberOfItems);
    }

    /// Remove the last item in the list
    // so that their active opponent cannot figure out a score for an active game
    if (scoresOverTime.length > 1) {
      scoresOverTime.removeLast();
    }

    /// Store scores, personal record, and win loss record in map
    playerRecords['scoresOverTimeList'] = scoresOverTime;
    playerRecords['personalRecord'] = personalRecord;
    playerRecords['winLossTieRecord'] = winLossTieRecord;
    playerRecords['personalRecordReps'] = personalRecordReps;

    return playerRecords;
  }

  /// Gets the current win loss record of this userID
  Future<Map> getCurrentWinLossTieRecord(userID, gameRulesID) async {
    Map currentWinLossTieRecord = {};

    Map playerRecordScores = await databaseServices.fetchPlayerRecordsByGameRules(userID: userID, gameRulesID: gameRulesID);
    if (playerRecordScores['winLossTieRecord'] == null) {
      currentWinLossTieRecord = {'win': 0, 'loss': 0, 'tie': 0};
    } else {
      currentWinLossTieRecord = playerRecordScores['winLossTieRecord'];
    }

    return currentWinLossTieRecord;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Update win loss record methods
  /// ***********************************************************************
  /// ***********************************************************************

  /// Update player's win loss record
  void updateWinLossRecord(
      {required String playerOneUserID,
      required String playerTwoUserID,
      required String gameRulesId,
      required Map playerGameOutcomes}) async {

    // get existing winLossTie records, for both players
    Map currentPlayerWinLossTieRecord = await getCurrentWinLossTieRecord(playerOneUserID, gameRulesId);
    Map opponentPlayerWinLossTieRecord = await getCurrentWinLossTieRecord(playerTwoUserID, gameRulesId);

    // determine new winLossTie records, for both players
    Map newCurrentPlayerWinLossTieRecord =
        calculateNewWinLossTieRecord(currentPlayerWinLossTieRecord, playerGameOutcomes, playerOneUserID);
    Map newOpponentPlayerWinLossTieRecord =
        calculateNewWinLossTieRecord(opponentPlayerWinLossTieRecord, playerGameOutcomes, playerTwoUserID);

    // update winLossTieRecords, for both players
    databaseServices.updateWinLossTieRecord(playerOneUserID, gameRulesId, newCurrentPlayerWinLossTieRecord);
    databaseServices.updateWinLossTieRecord(playerTwoUserID, gameRulesId, newOpponentPlayerWinLossTieRecord);
  }

  /// Takes current win loss record
  /// and increments the record based on the player's outcome
  /// returns this win loss record
  Map calculateNewWinLossTieRecord(Map playerWinLossTieRecord, Map playerGameOutcomes, String userID) {
    Map newWinLossTieRecord = playerWinLossTieRecord;

    switch (playerGameOutcomes[userID]) {
      case constants.cPlayerGameOutcomeWin:
        {
          newWinLossTieRecord['win'] = playerWinLossTieRecord['win'] + 1;
        }
        break;
      case constants.cPlayerGameOutcomeWinByForfeit:
        {
          newWinLossTieRecord['win'] = playerWinLossTieRecord['win'] + 1;
        }
        break;
      case constants.cPlayerGameOutcomeLose:
        {
          newWinLossTieRecord['loss'] = playerWinLossTieRecord['loss'] + 1;
        }
        break;
      case constants.cPlayerGameOutcomeLoseByForfeit:
        {
          newWinLossTieRecord['loss'] = playerWinLossTieRecord['loss'] + 1;
        }
        break;
      case constants.cPlayerGameOutcomeTie:
        {
          newWinLossTieRecord['tie'] = playerWinLossTieRecord['tie'] + 1;
        }
        break;
      default:
        {
          // do nothing
        }
        break;
    }

    return newWinLossTieRecord;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Build content for match versus card displayed on match screen
  /// ***********************************************************************
  /// ***********************************************************************

  Map buildMatchVersusCardContent(matchesMap, String matchStatus, opponentUserID, userID) {
    Map matchesMapWithExtraData = matchesMap;

    /// Get status of overall game
    // option: OPEN (one or both players to play)
    // option: CLOSED (both have played, or there are forfeits)
    String gameStatus = matchesMapWithExtraData['gameStatus'];

    /// Get state of the players in this game
    // OPEN options: open, pending (played but waiting on other player)
    // CLOSED options: win, lose, tie, win by forfeit, lose by forfeit, both forfeit
    String thisPlayerGameOutcome = matchesMapWithExtraData['playerGameOutcomes'][userID];
    String opponentPlayerGameOutcome = matchesMapWithExtraData['playerGameOutcomes'][opponentUserID];

    /// ***********************************************************************
    /// GameStatus = closed
    /// ***********************************************************************

    /// Both players played so the game has closed
    /// This player has either won, lost, tied, won by forfeit, lost by forfeit
    if (gameStatus == 'closed') {
      String opponentStatus;
      String thisPlayerVideo = '';
      String opponentPlayerVideo = '';
      Map thisPlayerMap = {};
      Map opponentPlayerMap = {};

      /// both have forfeited
      if (matchStatus == constants.cGameClosedBothPlayersLoseByForfeit) {
        opponentStatus = 'LOSES FOR NOT SHOWING UP';

        /// this player has won case
      } else if (matchStatus == constants.cGameClosedPlayerOneWinsPlayerTwoLoses) {
        opponentStatus = 'LOSS';

        /// this player has lost
      } else if (matchStatus == constants.cGameClosedPlayerOneLosesPlayerTwoWins) {
        opponentStatus = 'WINNER';

        /// this player wins by forfeit
      } else if (matchStatus == constants.cGameClosedPlayerOneWinsByForfeitPlayerTwoLosesByForfeit) {
        opponentStatus = 'LOSES FOR NOT SHOWING UP';

        /// this player loses by forfeit
      } else if (matchStatus == constants.cGameClosedPlayerOneLosesByForfeitPlayerTwoWinsLosesByForfeit) {
        opponentStatus = 'WIN BY FORFEIT';

        /// both players tied
      } else if (matchStatus == constants.cGameClosedPlayerOneTiesPlayerTwoTies) {
        opponentStatus = 'TIE';

        /// we didn't handle a case so do this
      } else {
        opponentStatus = 'ERROR';
      }
      matchesMapWithExtraData['opponentStatus'] = opponentStatus;

      /// Manage video player URL for this user
      // if it doesn't exist, sets it to an empty string so the UI will not show a button to watch the video
      if (matchesMapWithExtraData['playerVideos'][userID] != null) {
        thisPlayerVideo = matchesMapWithExtraData['playerVideos'][userID];
      }

      /// Manage video player URL for opponent
      // if it doesn't exist, sets it to an empty string so the UI will not show a button to watch the video
      if (matchesMapWithExtraData['playerVideos'][opponentUserID] != null) {
        opponentPlayerVideo = matchesMapWithExtraData['playerVideos'][opponentUserID];
      }

      thisPlayerMap = {
        'playerNickname': '${matchesMapWithExtraData['playerNicknames'][userID]}',
        'playerScore': '${matchesMapWithExtraData['playerScores'][userID].toString()}',
        'playerGameOutcome': thisPlayerGameOutcome,
        'userID': userID,
        'playerVideoURL': '$thisPlayerVideo'
      };
      matchesMapWithExtraData['thisPlayer'] = thisPlayerMap;

      opponentPlayerMap = {
        'playerNickname': '${matchesMapWithExtraData['playerNicknames'][opponentUserID]}',
        'playerScore': '${matchesMapWithExtraData['playerScores'][opponentUserID].toString()}',
        'playerGameOutcome': opponentPlayerGameOutcome,
        'userID': opponentUserID,
        'playerVideoURL': '$opponentPlayerVideo',
      };
      matchesMapWithExtraData['opponentPlayer'] = opponentPlayerMap;

      /// ***********************************************************************
      /// Game Status = open
      /// ***********************************************************************
      /// This game is open so...
      // this player has played, or has not played yet

    } else if (matchesMapWithExtraData['gameStatus'] == 'open') {
      late String thisPlayerScore;
      late String thisPlayerVideo;
      late String opponentPlayerScore;
      late String opponentPlayerVideo;
      late String opponentStatus;

      /// Case: both players have NOT played yet
      if (matchStatus == constants.cGameOpenBothPlayersHaveNotPlayed) {
        thisPlayerScore = 'TBD';
        thisPlayerVideo = '';
        opponentPlayerScore = 'TBD';
        opponentPlayerVideo = '';
        opponentStatus = 'HAS NOT PLAYED YET';

        /// Case: This player played
        // but opponent has not played
      } else if (matchStatus == constants.cGameOpenPlayerOneHasPlayedPlayerTwoHasNotPlayed) {
        // this player has played
        thisPlayerScore = matchesMapWithExtraData['playerScores'][userID].toString();
        thisPlayerVideo =
            matchesMapWithExtraData['playerVideos'][userID] != null ? matchesMapWithExtraData['playerVideos'][userID] : '';
        opponentPlayerScore = 'TBD';
        opponentPlayerVideo = '';
        opponentStatus = 'HAS NOT PLAYED YET';

        /// Case: Opponent has played
        // but this player has not played
      } else if (matchStatus == constants.cGameOpenPlayerOneHasNotPlayedPlayerTwoHasPlayed) {
        thisPlayerScore = 'TBD';
        thisPlayerVideo = '';
        opponentPlayerScore = '?'; // hide the score from view
        opponentPlayerVideo = '';
        opponentStatus = 'WAITING FOR YOU TO PLAY';

        /// A case we didn't handle so do this..
        // TODO: inform users, and developers when this occurs. Eg. throw exception, display pop to inform user and option to go back to last working page
      } else {
        thisPlayerScore = 'X';
        thisPlayerVideo = '';
        opponentPlayerScore = 'X';
        opponentPlayerVideo = '';
        opponentStatus = 'Sorry, something is awry';
      }

      /// Store and add additional data into matchesMap
      matchesMapWithExtraData['hostMessage'] = {
        'title': 'PUSHUP SPRINT',
        'message': 'who can perform MORE pushups in 60 seconds?'
      };
      matchesMapWithExtraData['thisPlayer'] = {
        'playerNickname': '${matchesMapWithExtraData['playerNicknames'][userID]}',
        'playerScore': thisPlayerScore,
        'playerGameOutcome': '${matchesMapWithExtraData['playerGameOutcomes'][userID]}',
        'userID': userID,
        'playerVideoURL': thisPlayerVideo
      };
      matchesMapWithExtraData['opponentPlayer'] = {
        'playerNickname': '${matchesMapWithExtraData['playerNicknames'][opponentUserID]}',
        'playerScore': opponentPlayerScore,
        'playerGameOutcome': '${matchesMapWithExtraData['playerGameOutcomes'][opponentUserID]}',
        'userID': opponentUserID,
        'playerVideoURL': opponentPlayerVideo
      };
      matchesMapWithExtraData['opponentStatus'] = opponentStatus;
    }

    return matchesMapWithExtraData;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Build Host card at top of match screen
  /// ***********************************************************************
  /// ***********************************************************************

  /*Map buildHostCardContent(matchesMap, String matchStatus) {
    Map matchesMapWithExtraData = matchesMap;
    Map hostMessage = {};

    /// game closed, both players lose by forfeit
    if (matchStatus == constants.cGameClosedBothPlayersLoseByForfeit) {
      hostMessage = {
        'title': 'The Results are in...',
        'message': 'you both lose the 60 second pushup sprint because you both never showed up! SMH'
      };

      /// game closed, this player has won case
    } else if (matchStatus == constants.cGameClosedPlayerOneWinsPlayerTwoLoses) {
      hostMessage = {'title': 'The Results are in...', 'message': 'you win the 60 second pushup sprint!'};

      /// game closed, this player has lost
    } else if (matchStatus == constants.cGameClosedPlayerOneLosesPlayerTwoWins) {
      hostMessage = {'title': 'The Results are in...', 'message': 'you lose the 60 second pushup sprint!'};

      /// game closed, this player wins by forfeit
    } else if (matchStatus == constants.cGameClosedPlayerOneWinsByForfeitPlayerTwoLosesByForfeit) {
      hostMessage = {'title': 'The Results are in...', 'message': 'you win the 60 second pushup sprint!'};

      /// game closed, this player loses by forfeit
    } else if (matchStatus == constants.cGameClosedPlayerOneLosesByForfeitPlayerTwoWinsLosesByForfeit) {
      hostMessage = {
        'title': 'The Results are in...',
        'message': 'you lose the 60 second pushup sprint because you never showed up. Where is your sportsmanship!?'
      };

      /// game closed, both players tied
    } else if (matchStatus == constants.cGameClosedPlayerOneTiesPlayerTwoTies) {
      hostMessage = {'title': 'The Results are in...', 'message': 'you both tied the 60 second pushup sprint!'};

      /// game open: no one has played, this player has played, or opponent has played
    } else if (matchStatus == constants.cGameOpenBothPlayersHaveNotPlayed || matchStatus == constants.cGameOpenPlayerOneHasPlayedPlayerTwoHasNotPlayed || matchStatus == constants.cGameOpenPlayerOneHasNotPlayedPlayerTwoHasPlayed) {
      hostMessage = {'title': 'PUSHUP SPRINT', 'message': 'who can perform MORE pushups in 60 seconds?'};

      /// we didn't handle a case.. so show some error
    } else {
      hostMessage = {
        'title': 'Uh oh',
        'message': 'Something went wrong. I told the game masters and they\'re looking into the issue.'
      };
    }

    matchesMapWithExtraData['hostMessage'] = hostMessage;
    return matchesMapWithExtraData;
  }*/

  /// ***********************************************************************
  /// ***********************************************************************
  /// Manage scoring
  /// ***********************************************************************
  /// ***********************************************************************

  void rewardPlayerWithNutritionOrSleepPoints({required String userID, required GameModel2 gameInfo, required GameModel2Extras gameInfoExtras, required String subScoreType}) {
    /// Instantiate and setup pre-requirements
    String playerOneUserID = userID;

    /// Check whether this is the first photo of the day to be added
    // do later

    /// Add a nutrition point to player sub score
    gameInfo = addSubScoreToGameObject(gameInfo: gameInfo, userID: playerOneUserID, subScoreType: subScoreType);

    /// Calculate total score
    num totalScore = calculateTotalScore(gameInfo.playerSubScores[playerOneUserID]);

    /// Add totalScore to Game Object
    gameInfo = updateGameObjectWithTotalScore(gameInfo: gameInfo, totalScore: totalScore, userID: playerOneUserID);

    /// Save to match document
    databaseServices.updateMatches(gameInfo, gameInfoExtras);
    databaseServices.updateMatchesFlat(gameInfo, gameInfoExtras);
  }

  GameModel2 addSubScoreToGameObject({required GameModel2 gameInfo, required String userID, required String subScoreType}) {
    /// this takes a number and a score field type (nutrition, sleep, form)
    /// to update with a new playerSubScore

    // Increment score for a specific player
    int newPlayerSubScore = gameInfo.playerSubScores[userID]['$subScoreType'] + 1;
    gameInfo.playerSubScores[userID]['$subScoreType'] = newPlayerSubScore;

    // return gameInfo Object
    return gameInfo;
  }

  num calculateTotalScore(Map playerSubScores) {
    // requires a map of player sub scores
    // containing existing match data

    // loop through and sum all values to calculate total score
    num totalScore = 0;
    playerSubScores.keys.forEach((k) {
      totalScore = totalScore + playerSubScores[k];
    });

    // return a total score number
    return (totalScore);
  }

  /// add the total score, calculated from all sub scores, to the game object
  GameModel2 updateGameObjectWithTotalScore({required GameModel2 gameInfo, required num totalScore, required String userID}) {
    // store total score, as integer, in game object
    gameInfo.playerScores[userID] = totalScore.toInt();

    return gameInfo;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Nutrition: image capturing
  /// ***********************************************************************
  /// ***********************************************************************

  /// Uploads the picture to firebase storage and generates a downloadURL
  Future<String> uploadPicture(String imagePath, Map gameMap)  async {
    String foodPicID = createUUID();
    String picLocation = 'food_pics/$foodPicID.png'; // todo create constant for food_pics directory
    File imageFile = File(imagePath);

    /// save image
    await databaseServices.saveFoodPictureToStorage(picLocation, imageFile);

    /// Returns the directory and image name
    return picLocation;
  }

  void addNutritionOrSleepPoints({required Map gameMap, required String userID, required String subScoreType}) {
    /// Instantiate and setup required parameters
    String playerOneUserID = userID;
    MatchService matchService = MatchService();
    String playerTwoUserID = getOpponentUserID(gameMap, playerOneUserID);

    /// Convert matchMap into Game Object and Game Extras Object
    GameModel2 gameInfo = matchService.createGameObject(gameMap);
    GameModel2Extras gameInfoExtras = matchService.createGameExtrasObject(gameMap, playerOneUserID);

    /// This service determines if the player should be rewarded points
    // and calculates totalScore
    // and updates DB's match document
    String _subScoreType = subScoreType;
    matchService.rewardPlayerWithNutritionOrSleepPoints(userID: playerOneUserID, gameInfo: gameInfo, gameInfoExtras: gameInfoExtras, subScoreType: _subScoreType);
  }

  ///Updates both users match documents
  Future<void> updateMatchWithFoodImageURL({required String firebaseImageURL, required String matchID, required String matchGroupID, required String playerOneUserID, required String playerOneNickname, required String playerTwoUserID, required Map dates}) async {
    String test = 'test description';
    Map picMap = {'downloadURL': firebaseImageURL,
      'foodDescription': test,
      'userID': playerOneUserID,
      'nickname': playerOneNickname,
      'dateTime': DateTime.now()};

    /// Update dates
    // discord bot uses this to determine what was changed last
    dates['foodUpdated'] = DateTime.now();

    /// Updates current user
    await databaseServices.saveFoodImageURLtoMatch(
        picMap: picMap,
        groupID: matchGroupID,
        userID: playerOneUserID,
        matchID: matchID,
        dates: dates);

    /// Updates opponent match document
    await databaseServices.saveFoodImageURLtoMatch(
        picMap: picMap,
        groupID: matchGroupID,
        userID: playerTwoUserID,
        matchID: matchID,
        dates: dates);

    /// Update matchesAll flat document
    databaseServices.saveFoodImageURLtoMatchFlat(
        picMap: picMap,
        matchID: matchID,
        dates: dates);
  }


}
