import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/widgets/open_challenge_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OpenChallengeCards extends StatefulWidget {
  @override
  _OpenChallengeCardsState createState() => _OpenChallengeCardsState();
}

class _OpenChallengeCardsState extends State<OpenChallengeCards> {
  final Stream<QuerySnapshot> _openChallengesStream = FirebaseFirestore.instance
      .collection('games')
      .where('gameStatus', isEqualTo: 'open')
      //.where('creatorID', isNotEqualTo: globals.dojoUser.uid)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _openChallengesStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Contact cat support', style: Theme.of(context).textTheme.bodyText1);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Analyzing opponents...', style: Theme.of(context).textTheme.bodyText1);
        }

        return
          ListView(
          scrollDirection: Axis.horizontal,
          children: snapshot.data!.docs.map<Widget>((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return OpenChallengeCard(
              avatarImage: 'images/avatar-blank.png',
              //avatarFirstLetter: data['player1Nickname'][0].toUpperCase(),
              avatarFirstLetter: data['player1Nickname'][0],
              title: data['title'],
              opponentName: data['player1Nickname'],
              gameID: data['gameID'],
              gameTypeID: data['gameTypeID']
            );
          }).toList(),
        );
      },
    );
  }
}

// class OpenChallengeCardModel {
//   OpenChallengeCardModel(
//       {required this.id,
//         required this.title,
//         required this.opponentName,
//       });
//
//   final int id;
//   final String title;
//   final String opponentName;
// }

// class OpenChallengeCardData {
//   static List<OpenChallengeCardModel> openChallengeCards = [
//     OpenChallengeCardModel(
//       id: 0,
//       title: 'Pushups',
//       opponentName: 'HeadKick',
//     ),
//     OpenChallengeCardModel(
//       id: 0,
//       title: 'Squats',
//       opponentName: 'HeadKick',
//     ),
//     OpenChallengeCardModel(
//       id: 0,
//       title: 'Situps',
//       opponentName: 'HeadKick',
//     ),
//   ];
// }

