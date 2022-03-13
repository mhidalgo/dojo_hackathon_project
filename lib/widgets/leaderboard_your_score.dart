import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles.dart';
import 'package:flutter/material.dart';
import '../style/colors.dart';

//ignore: must_be_immutable
class LeaderboardYourScore extends StatelessWidget {
  LeaderboardYourScore({
    Key? key, required this.score, this.playerLeaderboardStatus = 'pending',
  }) : super(key: key);

  final int score;

  /// Manage content that shows in module
  // options: pending, confirmed, winner
  final String playerLeaderboardStatus;

  // Setup copy parameters
  String title = 'YOUR PENDING SCORE';
  bool displayMessage = true;
  String message = 'Default message';

  /// Manage content based on playerLeaderboardStatus
  void manageContentBasedOnPlayerLeaderboardStatus(){
    if (playerLeaderboardStatus == 'pending') {
      title = 'YOUR PENDING SCORE';
      displayMessage = true;
      message = 'Judges are reviewing your video for accuracy of your score. You\'ll be added to the leaderboard soon.';
    }

    if (playerLeaderboardStatus == 'confirmed') {
      title = 'YOUR CONFIRMED SCORE';
      displayMessage = true;
      message = 'Judges have confirmed your score so you\'ve officially been added to the leaderboard. A winner will be announced soon.';
    }

    if (playerLeaderboardStatus == 'winner') {
      title = 'YOUR WIN!';
      displayMessage = true;
      message = 'You are the winner with the most reps! An trophy NFT with your video performance has been dropped in your wallet';
    }
  }

  @override
  Widget build(BuildContext context) {
    manageContentBasedOnPlayerLeaderboardStatus();
    return Stack(
      children: [
        Container(
          width: (MediaQuery.of(context).size.width) * .90,
          padding: EdgeInsets.all(16.0),
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: borderRadius1(),
            color: primarySolidCardColor.withOpacity(0.7),
          ),
          child: Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(title,
                        style: Theme.of(context).textTheme.caption),
                  ],
                ),
                SizedBox(height:16),
                Text(message,
                    style: Theme.of(context).textTheme.bodyText2),
                SizedBox(height:16),
                PlayerResultRow(
                  score: score,
                ),
                SizedBox(height:8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PlayerResultRow extends StatelessWidget {
  const PlayerResultRow({
    Key? key,
    required this.score,
    this.scoreType = 'MAKES',
  }) : super(key: key);

  final int score;
  final String scoreType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width) * .90,
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
         /* Icon(
            playerResultIcon,
            color: Colors.green,
            size: 36,
          ),*/
          Expanded(
            child: Column(
              children: [
                Row(children: [
                  /*Text(
                    '?',
                    //textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.caption,
                  ),*/
                  SizedBox(width: 16),
                  Text(
                    'You',
                    //textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],),
              ],
            ),
          ),
          Expanded(
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.end,
              //mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      score.toString(),
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    SizedBox(width:16),
                    BodyText4(text: scoreType),
                  ],
                ),
              ],
            ),
          ),
          /*Text(
            '?',
            //textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.caption,
          ),
          SizedBox(width: 16),
          Text(
            'You',
            //textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodyText1,
          ),*/
          SizedBox(width: 8),
          /*Text(
            score.toString(),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.headline3,
          ),
          BodyText4(text: scoreType),*/
        ],
      ),
    );
  }
}
