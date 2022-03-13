import 'package:dojo_app/style/style_misc.dart';
import 'package:flutter/material.dart';
import '../style/colors.dart';

class OnePlayerResultsCard extends StatelessWidget {
  const OnePlayerResultsCard({
    Key? key, required this.score, required this.duration
  }) : super(key: key);

  final int score;
  final int duration;

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('YOUR RESULTS',
                        style: Theme.of(context).textTheme.caption),
                  ],
                ),
                SizedBox(height:8),
                PlayerResultRow(
                  playerResultIcon: Icons.timer_rounded,
                  value: '$duration',
                  description: 'SECONDS'
                ),
                SizedBox(height:8),
                PlayerResultRow(
                    playerResultIcon: Icons.flag,
                    value: '$score',
                    description: 'REPS'
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
    required this.playerResultIcon,
    required this.value,
    required this.description,
  }) : super(key: key);

  final IconData playerResultIcon;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      //crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Icon(
          playerResultIcon,
          color: Colors.green,
          size: 36,
        ),
        SizedBox(width: 16),
        Text(
          value,
          //textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.headline4,
        ),
        SizedBox(width: 8),
        Text(
          description,
          //textAlign: TextAlign.,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    );
  }
}
