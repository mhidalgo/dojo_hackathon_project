import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MatchScoreCard extends StatelessWidget {
  const MatchScoreCard({Key? key, required this.matchDetailsMap}) : super(key: key);
  final Map matchDetailsMap;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: (MediaQuery.of(context).size.width) * .90,
        margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
        padding: EdgeInsets.fromLTRB(0, 4, 0, 8),
        decoration: BoxDecoration(
          color: primaryTransparentCardColor,
          borderRadius: borderRadius1(),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
              child: Row(
                children: <Widget>[
                  FaIcon(
                    FontAwesomeIcons.chartBar,
                    size: 16,
                    color: offWhiteColor,
                  ),
                  SizedBox(width: 8),
                  Text('Scoring (PTS)', style: Theme.of(context).textTheme.headline6),
                  Expanded(child: SizedBox())
                ],
              ),
            ),
            SizedBox(height: 8),
            Divider(height: 1.0, thickness: 1.0, indent: 0.0),
            SizedBox(height: 12),
            Padding(
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
                          child: Text(matchDetailsMap['thisPlayer']['playerNickname'].toUpperCase(),
                              style: Theme.of(context).textTheme.caption)),
                      Text(
                        '${matchDetailsMap['playerSubScores'][matchDetailsMap['thisPlayer']['userID']]['form']}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      Text(
                        '${matchDetailsMap['playerSubScores'][matchDetailsMap['thisPlayer']['userID']]['nutrition']}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      Text(
                        '${matchDetailsMap['playerSubScores'][matchDetailsMap['thisPlayer']['userID']]['reps']}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      Text(
                        '${matchDetailsMap['playerSubScores'][matchDetailsMap['thisPlayer']['userID']]['sleep']}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
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
                        FittedBox(fit: BoxFit.fitWidth, child: Text('FORM', style: Theme.of(context).textTheme.headline6)),
                        SizedBox(height: 20),
                        FittedBox(fit: BoxFit.fitWidth, child: Text('NUTRITION', style: Theme.of(context).textTheme.headline6)),
                        SizedBox(height: 20),
                        FittedBox(fit: BoxFit.fitWidth, child: Text('REPS', style: Theme.of(context).textTheme.headline6)),
                        SizedBox(height: 20),
                        FittedBox(fit: BoxFit.fitWidth, child: Text('SLEEP', style: Theme.of(context).textTheme.headline6)),
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
                          child: Text(matchDetailsMap['opponentPlayer']['playerNickname'].toUpperCase(),
                              style: Theme.of(context).textTheme.caption)),
                      Text(
                        '${matchDetailsMap['playerSubScores'][matchDetailsMap['opponentPlayer']['userID']]['form']}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      Text(
                        '${matchDetailsMap['playerSubScores'][matchDetailsMap['opponentPlayer']['userID']]['nutrition']}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      Text(
                        '${matchDetailsMap['playerSubScores'][matchDetailsMap['opponentPlayer']['userID']]['reps']}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      Text(
                        '${matchDetailsMap['playerSubScores'][matchDetailsMap['opponentPlayer']['userID']]['sleep']}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 16,
                )
              ]),
            )
          ],
        ));
  }
}
