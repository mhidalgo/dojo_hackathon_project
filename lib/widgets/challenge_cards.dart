import '../style/colors.dart';
import 'package:dojo_app/models/challenge_card_model.dart';
import 'package:dojo_app/screens/archive/challenge_detail.dart';
import 'package:flutter/material.dart';

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    Key? key,
    required this.challenge,
  }) : super(key: key);

  final ChallengeCardModel challenge;

  challengeCardBorderRadius() {
    return BorderRadius.only(
      topLeft: Radius.circular(1),
      topRight: Radius.circular(1),
      bottomLeft: Radius.circular(1),
      bottomRight: Radius.circular(8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: primarySolidBackgroundColor,
      child: Ink(
        height: 126,
        width: 116,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(challenge.imagePath),
            fit: BoxFit.fill,
          ),
          borderRadius: challengeCardBorderRadius(),
        ),
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          borderRadius: challengeCardBorderRadius(),
          onTap: () {
            print('tap: ${challenge.id}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChallengeDetailScreen(
                  gameTypeID: challenge.id,
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    Text(challenge.title,
                        style: Theme.of(context).textTheme.bodyText1),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(height: 8),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('${challenge.duration}',
                        style: Theme.of(context).textTheme.bodyText2),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('PR: ${challenge.personalRecord}',
                        style: Theme.of(context).textTheme.bodyText2),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
