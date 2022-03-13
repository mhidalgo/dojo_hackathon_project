import 'package:dojo_app/screens/game/game_screen_wrapper.dart';
import 'package:dojo_app/screens/view_replay/view_replay_wrapper.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles.dart';
import 'package:dojo_app/widgets/circle_avatar.dart';
import 'package:dojo_app/widgets/data_pill.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';
import '../style/colors.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/constants.dart' as constants;

/// Versus cards have several different variations based on the state of that match
// States
// - both players completed
// - you never had a match
// - no one has played yet
// - you have not played yet
// - opponent has not played yet
// - play by this date/time has expired...
// -- both forfeit
// -- you forfeit
// -- opponent forfeit

// Secondary States
// - judging status: open, pending, closed

// Button Options
// - Watch your video
// - Watch opponent video
// - Start Challenge (game screen)
// - Waiting for opponent (disabled)
// - No game available (hidden)

class MatchesVersusCard extends StatelessWidget {
  MatchesVersusCard({
    Key? key,
    required this.thisPlayer,
    required this.opponentPlayer,
    required this.opponentStatus,
    required this.matchesMap,
    this.playerOneAvatar = 'images/avatar-blank.png',
    this.playerTwoAvatar = 'images/avatar-blank.png',
    this.challengeButtonStatus = constants.cChallengeButtonStatusHidden,
    this.challengeButtonText = 'hidden',
    required this.playerOneRecords,
    required this.playerTwoRecords,
  }) : super(key: key);

  // button to game screen
  late final String challengeButtonStatus;
  late final String challengeButtonText;

  // general data requirements
  late final Map matchesMap;
  late final String gameMode = matchesMap['gameMode'];
  late final String groupID = matchesMap['groupID'];
  late final String id = matchesMap['id'];

  // player 1
  final Map thisPlayer;
  late final String playerOneUserID = thisPlayer['userID'];
  late final String playerOneName = thisPlayer['playerNickname'];
  late final String playerOneScore = thisPlayer['playerScore'];
  late final String playerOneVideo = thisPlayer['playerVideoURL'];
  late final String playerOneGameOutcome = thisPlayer['playerGameOutcome'];
  late final String playerOneAvatar;
  late final Map playerOneRecords;

  // player 2
  final Map opponentPlayer;
  final String opponentStatus;
  late final String playerTwoUserID = opponentPlayer['userID'];
  late final String playerTwoName = opponentPlayer['playerNickname'];
  late final String playerTwoScore = opponentPlayer['playerScore'];
  late final String playerTwoVideo = opponentPlayer['playerVideoURL'];
  late final String playerTwoGameOutcome = opponentPlayer['playerGameOutcome'];
  late final String playerTwoAvatar;
  late final Map playerTwoRecords;

  /// Player requests 3rd party judge to review their match
  void sendToThirdPartyJudgeButtonAction() {
    DatabaseServices databaseServices = DatabaseServices();

    // create document in JUDGING collection
    databaseServices.create3rdPartyJudgeRequest(matchesMap);

    // update match document to indicate the game is currently being reviewed by a judge
    databaseServices.updateMatchWithJudgingStatus(
        matchesMap, constants.cGameStatusSecondaryJudgePending, playerOneUserID, playerTwoUserID);

    // matchesAll collection: update match document to indicate the game is currently being reviewed by a judge
    databaseServices.updateMatchWithJudgingStatusFlat(
        matchesMap, constants.cGameStatusSecondaryJudgePending, playerOneUserID, playerTwoUserID);
  }

  Widget displaySendToThirdPartyJudgeButton() {
    // set initial button parameters
    String title = 'Send to 3rd party Judge';
    Color buttonColor = onPrimaryBlack;
    bool buttonEnabled = true;

    // determine new button parameters
    if (matchesMap['judging']['status'] == constants.cGameStatusSecondaryJudgeOpen) {
      title = 'Send to 3rd party judge';
      buttonColor = onPrimaryBlack;
    } else if (matchesMap['judging']['status'] == constants.cGameStatusSecondaryJudgePending) {
      title = 'Waiting for judge to review';
      buttonColor = inactiveSolidCardColor;
      buttonEnabled = false;
    } else if (matchesMap['judging']['status'] == constants.cGameStatusSecondaryJudgeClosed) {
      title = 'Judging completed';
      buttonColor = inactiveSolidCardColor;
      buttonEnabled = false;
    }

    // return button with above parameters
    return LowEmphasisButtonWithBorder(
      title: title,
      onPressAction: () {
        if (buttonEnabled) {
          sendToThirdPartyJudgeButtonAction();
        } else {
          print('tap, do nothing');
        }
      },
      buttonColor: buttonColor,
      buttonEnabled: buttonEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Manage visibility of watch buttons
    bool displayPlayerOneWatchButton = false;
    bool displayPlayerTwoWatchButton = false;

    // player 1 (this player) watch button visibility
    if (playerOneVideo != '' || playerOneVideo.isNotEmpty) {
      displayPlayerOneWatchButton = true;
    }

    // player 2 (opponent) watch button visibility
    if (playerTwoVideo != '') {
      displayPlayerTwoWatchButton = true;
    }

    /// Manage visibility of challenge button
    bool displayChallengeButton = false;
    if (challengeButtonStatus == constants.cChallengeButtonStatusEnabled) {
      displayChallengeButton = true;
    }

    return Container(
      width: (MediaQuery.of(context).size.width) * .90,
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryTransparentCardColor,
        borderRadius: borderRadius1(),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * .30,
                child: MatchCardPlayer(
                  playerName: playerOneName,
                  playerVideo: playerOneVideo,
                  playerScore: playerOneScore,
                  playerGameOutcome: playerOneGameOutcome,
                  winLossTieRecord: playerOneRecords['winLossTieRecord'],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * .10,
                child: Column(
                  children: <Widget>[
                    BodyText1BoldItalic(text: 'VS.'),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * .30,
                child: MatchCardPlayer(
                  playerName: playerTwoName,
                  playerVideo: playerTwoVideo,
                  playerScore: playerTwoScore,
                  playerGameOutcome: playerTwoGameOutcome,
                  winLossTieRecord: playerTwoRecords['winLossTieRecord'],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(height: 1.0, thickness: 1.0, indent: 0.0),
          SizedBox(height: 16),
          MatchCardOpponent(
            playerAvatar: playerTwoAvatar,
            playerName: playerTwoName,
            playerStatus: opponentStatus,
          ),
          SizedBox(height: 16),
          Visibility(
              visible: (displayChallengeButton || (displayPlayerOneWatchButton && displayPlayerTwoWatchButton)),
              child: Divider(height: 1.0, thickness: 1.0, indent: 0.0)),

          /// Display challenge button to load game screen
          Visibility(
            visible: (displayChallengeButton) ? true : false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 16),
                HighEmphasisButton(
                  title: '$challengeButtonText',
                  onPressAction: () {
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            type: PageTransitionType.topToBottom,
                            alignment: Alignment.bottomCenter,
                            child: GameScreenWrapper(
                              userID: playerOneUserID,
                              gameMode: gameMode,
                              groupID: groupID,
                              id: id,
                              gameMap: matchesMap,
                            )));
                  },
                ),
              ],
            ),
          ),

          Visibility(
            visible: (displayPlayerOneWatchButton && displayPlayerTwoWatchButton) ? true : false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 16),
                LowEmphasisButtonWithBorder(
                  title: 'Watch Replay',
                  onPressAction: () {
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            type: PageTransitionType.topToBottom,
                            alignment: Alignment.bottomCenter,
                            child: ViewReplayWrapper(
                              playerOneVideo: playerOneVideo,
                              playerOneUserID: playerOneUserID,
                              gameID: id,
                            )));
                  },
                ),
                SizedBox(height: 8),
                displaySendToThirdPartyJudgeButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MatchCardPlayer extends StatelessWidget {
  const MatchCardPlayer({
    Key? key,
    this.cardType,
    required this.playerName,
    this.playerVideo = '',
    required this.playerScore,
    required this.playerGameOutcome,
    required this.winLossTieRecord,
  }) : super(key: key);

  final int? cardType;
  final String playerName;
  final String playerVideo;
  final String playerScore;
  final String playerGameOutcome;
  final String winLossTieRecord;

  @override
  Widget build(BuildContext context) {
    // determine if score should be colored as the winner
    bool colorThisScore = false;
    Color scoreColor = Color(0xFFFFFFFF);
    if (playerGameOutcome == 'win') {
      colorThisScore = true;
      scoreColor = primaryColorExtraLight1;
    } else if (playerGameOutcome == 'lose' || playerGameOutcome == 'tie') {
      scoreColor = secondaryTextColor;
    } else if (playerGameOutcome == 'pending') {
      scoreColor = secondaryTextColor;
    } else if (playerGameOutcome == 'win by forfeit' || playerGameOutcome == 'lose by forfeit') {
      scoreColor = secondaryTextColor;
    }

    return Material(
      color: primarySolidCardColor.withOpacity(0.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Text(
                  playerName,
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          //avatarIcon(playerAvatar, cardType),
          BodyText5Bold(text: '$playerScore', fontColor: scoreColor),
          //SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'PTS',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          SizedBox(height: 4),
          DataPill(data: '  $winLossTieRecord  '),
        ],
      ),
    );
  }
}

class MatchCardOpponent extends StatelessWidget {
  const MatchCardOpponent({Key? key, required this.playerAvatar, required this.playerName, this.playerStatus = ''})
      : super(key: key);

  final String playerAvatar;
  final String playerName;
  final String playerStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Column(
                children: [
                  CustomCircleAvatar(
                    avatarImage: playerAvatar,
                    radius: 32.0,
                    avatarFirstLetter: playerName[0],
                  ),
                ],
              ),
              // opponent name, status
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // opponent name
                  Row(
                    children: [
                      Text('$playerName', style: Theme.of(context).textTheme.bodyText1),
                    ],
                  ),
                  // status
                  Row(
                    children: [
                      Text('$playerStatus', style: Theme.of(context).textTheme.caption),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Data bubbles
          Row(
            children: [
              Container(),
            ],
          ),
        ],
      ),
    );
  }
}
