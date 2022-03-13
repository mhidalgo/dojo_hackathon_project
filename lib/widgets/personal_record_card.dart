import 'package:dojo_app/style/style_misc.dart';
import 'package:flutter/material.dart';
import '../style/colors.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';

class PersonalRecordCard extends StatelessWidget {
  PersonalRecordCard({
    Key? key, required this.personalRecordScore, this.newPersonalRecord = false, this.thisGamesScore = 0,
  }) : super(key: key);

  final int personalRecordScore;
  final bool newPersonalRecord;
  final int thisGamesScore;
  late final ConfettiController _controllerTopCenter = ConfettiController(duration: const Duration(seconds: 10));

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    /// Determine if this is a new personal record to update UI
    String description = 'Personal Record';
    int scoreToDisplay = personalRecordScore;
    Color cardColor = primarySolidCardColor.withOpacity(0.7);
    if (thisGamesScore > personalRecordScore) {
      description = 'New Personal Record';
      scoreToDisplay = thisGamesScore;
      cardColor = primaryColorLight1.withOpacity(0.7);
      _controllerTopCenter.play();
    }

    return Stack(
      children: [
        Container(
          width: (MediaQuery.of(context).size.width) * .90,
          padding: EdgeInsets.all(16.0),
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: borderRadius1(),
            color: cardColor,
          ),
          child: Container(
            child: Container(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _controllerTopCenter,
                      blastDirection: pi / 2,
                      maxBlastForce: 5, // set a lower max blast force
                      minBlastForce: 2, // set a lower min blast force
                      emissionFrequency: 0.05,
                      numberOfParticles: 50, // a lot of particles at once
                      gravity: 1,
                    ),
                  ),
                  PlayerResultRow(
                      playerResultIcon: Icons.show_chart,
                      value: '$scoreToDisplay',
                      description: '$description',
                  ),
                ],
              ),
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
          description,
          //textAlign: TextAlign.,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(width: 8),
        Text(
          value,
          //textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.headline4,
        ),
      ],
    );
  }
}
