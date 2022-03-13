import 'package:dojo_app/screens/leaderboard2/leaderboard2_bloc.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles.dart';
import 'package:flutter/material.dart';
import '../style/colors.dart';

class Leaderboard extends StatelessWidget {
  const Leaderboard({
    Key? key, required this.score, required this.rank, required this.playerNickname, required this.leaderboardController
  }) : super(key: key);

  final int score;
  final int rank;
  final String playerNickname;
  final Leaderboard2Bloc leaderboardController;


  @override
  Widget build(BuildContext context) {
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
                    Text('LEADERBOARD',
                        style: Theme.of(context).textTheme.caption),
                  ],
                ),
                SizedBox(height:16),
                /*Text('Judges are reviewing your video for accuracy of your score. You\'ll be added to the leaderboard soon.',
                    style: Theme.of(context).textTheme.bodyText2),
                SizedBox(height:16),*/
                StreamBuilder<List>(
                  stream: leaderboardController.leaderboardDataStream,
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      final leaderboardData = snapshot.data as List;
                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: leaderboardData.length,
                            itemBuilder: (BuildContext context, int index) {
                              Map someData = leaderboardData[index];
                              return PlayerResultRow(
                                rank: index + 1,
                                score: someData['score'],
                                playerNickname: someData['playerNickname'],
                              );
                            }),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                /*PlayerResultRow(
                  rank: rank,
                  score: score,
                  playerNickname: playerNickname,
                ),
                SizedBox(height:8),*/
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
    required this.score, required this.rank, required this.playerNickname,
    this.scoreType = 'MAKES',
  }) : super(key: key);

  final int score;
  final String scoreType;
  final int rank;
  final String playerNickname;

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
                  Text(
                    '$rank.',
                    //textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SizedBox(width: 16),
                  Text(
                    playerNickname,
                    //textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyText2,
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
                    //BodyText4(text: scoreType),
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
