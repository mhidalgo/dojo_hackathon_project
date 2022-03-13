import 'package:dojo_app/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';

class OpenChallengeCard extends StatefulWidget {
  const OpenChallengeCard({
    Key? key,
    this.avatarImage = 'images/avatar-blank.png',
    this.avatarFirstLetter = 'X',
    required this.title,
    required this.opponentName,
    required this.gameID,
    required this.gameTypeID,
  }) : super(key: key);

  final String avatarImage;
  final String avatarFirstLetter;
  final String title;
  final String opponentName;
  final String gameID;
  final int gameTypeID;

  @override
  _OpenChallengeCardState createState() => _OpenChallengeCardState();
}

class _OpenChallengeCardState extends State<OpenChallengeCard> {
  @override
  Widget build(BuildContext context) {
    Map tempMap = {};
    return Card(
      child: InkWell(
        splashColor: Colors.red.withAlpha(30),
        onTap: () {
          print('tap');
        },
        child: Container(
          height: 80,
          width: 232,
          child: ListTile(
            leading: CustomCircleAvatar(
                avatarFirstLetter: widget.avatarFirstLetter,
                radius: 25.0,
                avatarImage: widget.avatarImage),
            title: Text(widget.title),
            subtitle: Text('vs. ${widget.opponentName}'),
          ),
        ),
      ),
    );
  }
}
