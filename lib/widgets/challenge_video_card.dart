import 'package:flutter/material.dart';

// MostRecentChallengeVideo ListItem
class ChallengeVideoCard2 extends StatelessWidget {
  const ChallengeVideoCard2({
    Key? key,
    required this.thumbnail,
    required this.title,
    required this.gameInfo,
    required this.score,
  }) : super(key: key);

  final String thumbnail;
  final String title;
  final String gameInfo;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.red.withAlpha(30),
        onTap: (){
          print('tap');
        },
        child: Container(
          margin: EdgeInsets.all(8),
          // height: 100,
          // width: 100,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 88,
                    width: 128,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(thumbnail),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      size: 32.0,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4.0, 0.0, 0.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                        Text(
                          gameInfo,
                          style: Theme.of(context).textTheme.caption,
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
                        Text(
                          '$score repetitions',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




