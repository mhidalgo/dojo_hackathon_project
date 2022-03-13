import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/widgets/versus_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;

class PastChallengeCard extends StatefulWidget {
  PastChallengeCard({this.gameTypeID = 0});

  // determines which category of games to display
  final int gameTypeID;

  @override
  _PastChallengeCardState createState() => _PastChallengeCardState();
}

class _PastChallengeCardState extends State<PastChallengeCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _pastChallengesStream =
        FirebaseFirestore.instance
            .collection('games')
            .where('gameStatus', isEqualTo: 'closed')
            .where('players', arrayContains: globals.dojoUser.uid)
            .where('gameTypeID', isEqualTo: widget.gameTypeID)
            //.orderBy('dateUpdated')
            .snapshots();

    return Container(
      height: 205,
      child: StreamBuilder<QuerySnapshot>(
        stream: _pastChallengesStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return ListView(
            scrollDirection: Axis.horizontal,
            children:
                snapshot.data!.docs.map<Widget>((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return VersusCard2(
                titleVisibility: false,
                displayAcceptLevelButton: false,
                cardType: 1,
                cardTitle: '${data['title']} Challenge',
                cardSubTitle: 'AMRAP, ${data['duration']} seconds',
                playerOneName: '${data['player1Nickname']}',
                playerOneAvatar: 'images/avatar-blank.png',
                playerOneScore: '${data['player1Score']}x',
                playerOneVideo: '${data['downloadURL']}',
                playerTwoName: '${data['player2Nickname']}',
                playerTwoAvatar: 'images/avatar-blank.png',
                playerTwoScore: '${data['player2Score']}x',
                playerTwoVideo: '${data['downloadURLp2']}',
              );
            }).toList(),
          );
        },
      ),
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
