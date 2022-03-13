import 'package:dojo_app/models/game_model2.dart';
import 'package:dojo_app/models/game_model2_extras.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles.dart';
import 'package:dojo_app/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';
import '../style/colors.dart';

class FormJudgementCard extends StatelessWidget {
  FormJudgementCard({
    Key? key, required this.questions, required this.gameInfo, required this.gameInfoExtras,
  }) : super(key: key);

  final Map questions;
  final GameModel2 gameInfo;
  final GameModel2Extras gameInfoExtras;

  late final String playerOneNickname = gameInfo.playerNicknames[gameInfoExtras.playerOneUserID];
  late final String playerTwoNickname = gameInfo.playerNicknames[gameInfoExtras.playerOneUserID];

  late final String playerOneFormGrade = getFormGrade(questions, gameInfoExtras.playerOneUserID);
  late final String playerTwoFormGrade = getFormGrade(questions, gameInfoExtras.playerTwoUserID);

  String getFormGrade(questions, userID){
    // Loop through this user's questions and total the score
    int maxScore = 9;
    num totalScore = 0;

    for(var i=0;i < questions[userID].length; i++){
      totalScore = totalScore + questions[userID][i]['answer'];
    }

    int formScore = ((totalScore / maxScore) * 100).round();
    String formGradeDisplay = '$formScore%';
    return formGradeDisplay;
  }

  String getEmojiValue(item){
    String emojiValue = 'TBD';

    switch(item) {
      case null: {
        emojiValue = 'TBD';
      }
      break;
      case 1: {
        emojiValue = '😢';
      }
      break;
      case 2: {
        emojiValue = '😐';
      }
      break;
      case 3: {
        emojiValue = '😄';
      }
      break;
    }
    return emojiValue;
  }

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BodyText2BoldItalic(text: 'Form Grading'),
                  ],
                ),
                SizedBox(height:16),
                SizedBox(
                    child: DisplayTotalFormGrade(
                        playerOneNickname: '${gameInfo.playerNicknames[gameInfoExtras.playerOneUserID]}',
                        playerTwoNickname: '${gameInfo.playerNicknames[gameInfoExtras.playerTwoUserID]}',
                        playerOneFormGrade: playerOneFormGrade,
                        playerTwoFormGrade: playerTwoFormGrade,
                    ),
                ),
                SizedBox(
                  height: 190 * double.parse(questions.length.toString()),
                  child: ListView.builder(
                    itemCount: questions.length + 1,
                    itemBuilder: (context, i){
                      String? playerOneValue = getEmojiValue(questions[gameInfoExtras.playerOneUserID][i]['answer']);
                      String? playerTwoValue = getEmojiValue(questions[gameInfoExtras.playerTwoUserID][i]['answer']);
                      String title = questions[gameInfoExtras.playerOneUserID][i]['shortDescription'];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          Text('$title', style: Theme.of(context).textTheme.caption),
                          SizedBox(height: 8),
                          PlayerResultRow(
                            playerNickname: '${gameInfo.playerNicknames[gameInfoExtras.playerOneUserID]}',
                            value: playerOneValue,
                          ),
                          SizedBox(height: 4),
                          PlayerResultRow(
                            playerNickname: '${gameInfo.playerNicknames[gameInfoExtras.playerTwoUserID]}',
                            value: playerTwoValue,
                          ),
                        ],
                      );
                    }
                  ),
                ),
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
    required this.value,
    required this.playerNickname,
  }) : super(key: key);

  final String value;
  final String playerNickname;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  CustomCircleAvatar(
                    avatarImage: 'images/avatar-blank.png',
                    radius: 12,
                    avatarFirstLetter: playerNickname[0].toUpperCase(),
                  ),
                  SizedBox(width: 16),
                  Text(
                    playerNickname,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                EmojiText(emoji: value),
              ],
            ),
          ],
        )
      ],
    );
  }
}

class DisplayTotalFormGrade extends StatelessWidget {
  const DisplayTotalFormGrade({Key? key, required this.playerOneNickname, required this.playerTwoNickname, required this.playerOneFormGrade, required this.playerTwoFormGrade}) : super(key: key);

  final String playerOneNickname;
  final String playerTwoNickname;
  final String playerOneFormGrade;
  final String playerTwoFormGrade;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: <Widget>[
        SizedBox(
          width: 16,
        ),
        //Current player scores
        Container(
          width: MediaQuery.of(context).size.width * .20,
          child: Column(
            children: <Widget>[
              FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(playerOneNickname.toUpperCase(),
                      style: Theme.of(context).textTheme.caption)),
              BodyText3BoldItalic(text: playerOneFormGrade),
            ],
          ),
        ),
        Expanded(child: SizedBox()),
        // Score Labels
        Container(
          width: MediaQuery.of(context).size.width * .20,
          child: Center(
            child: Column(
              children: <Widget>[
                Text(''),
                // FittedBox(fit: BoxFit.fitWidth, child: Text('OVERALL', style: Theme.of(context).textTheme.caption)),
                BodyText4(text: 'OVERALL'),
                SizedBox(height: 8),
              ],
            ),
          ),
        ),
        Expanded(child: SizedBox()),
        //Opponent Scores
        Container(
          width: MediaQuery.of(context).size.width * .20,
          child: Column(
            children: <Widget>[
              FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(playerTwoNickname.toUpperCase(),
                      style: Theme.of(context).textTheme.caption)),
              BodyText3BoldItalic(text: playerTwoFormGrade),
            ],
          ),
        ),
        SizedBox(
          width: 16,
        )
      ]),
    );
  }
}

