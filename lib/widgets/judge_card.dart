import 'package:dojo_app/constants.dart';
import 'package:dojo_app/screens/view_replay/view_replay_wrapper.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles.dart';
import 'package:dojo_app/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';

class JudgeCard extends StatefulWidget {
  const JudgeCard({
    Key? key,
    this.avatarImage = 'images/avatar-blank.png',
    this.avatarFirstLetter = 'X',
    required this.title,
    required this.gameID,
    required this.playerOneNickname,
    required this.playerOneScore,
    required this.playerOneVideo,
    required this.playerOneUserID,
    required this.judgeRequestID,
    required this.dateUpdated,
    this.cardType = 'open',
    required this.gameTitle,
  }) : super(key: key);

  final String title;
  final String gameID;
  final String avatarImage;
  final String avatarFirstLetter;
  final String playerOneNickname;
  final String playerOneScore;
  final String playerOneVideo;
  final playerOneUserID;
  final String judgeRequestID;
  final String dateUpdated;
  final String cardType;
  final String gameTitle;

  BoxDecoration determineCardBackgroundColor() {
    if (cardType == 'pending') {
      return judgeCardBoxDecorationPending();
    } else if (cardType == 'success') {
      judgeCardBoxDecorationSuccess();
    } else if (cardType == 'fail') {
      judgeCardBoxDecorationFail();
    }

    return judgeCardBoxDecoration();
  }

  @override
  _JudgeCardState createState() => _JudgeCardState();
}

class _JudgeCardState extends State<JudgeCard> {
  void redirectUser() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ViewReplayWrapper(
              playerOneVideo: widget.playerOneVideo,
              playerOneUserID: widget.playerOneUserID,
              gameID: widget.gameID,
              redirect: 'JudgeListWrapper()',
              userPointOfView: UserPointOfView.Judge,
              judgeRequestID: widget.judgeRequestID,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map tempMap = {};
    return Card(
      child: Ink(
        decoration: widget.determineCardBackgroundColor(),
        child: InkWell(
          splashColor: Colors.red.withAlpha(30),
          onTap: () {
            print('tap');
            redirectUser();
          },
          child: Container(
            height: 95,
            width: 232,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 12.0, bottom: 0.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CustomCircleAvatar(avatarFirstLetter: widget.playerOneNickname[0].toUpperCase(),
                          radius: 12.0,
                          avatarImage: widget.avatarImage),
                      SizedBox(width: 4),
                      Text(widget.playerOneNickname, style: Theme
                          .of(context)
                          .textTheme
                          .bodyText1),
                      SizedBox(width: 2),
                      // Text('(${widget.playerOneScore})'),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      BodyText6(text: widget.gameTitle)
                      // Text('(${widget.playerOneScore})'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration judgeCardBoxDecoration() {
  return BoxDecoration(
      borderRadius: borderRadius1(),
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFFB31217),
          Color(0xFFE52D27),
        ],

      ));
}

BoxDecoration judgeCardBoxDecorationPending() {
  return BoxDecoration(
      borderRadius: borderRadius1(),
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFF1B2E57),
          Color(0xFF1B2E57),
        ],

      ));
}

BoxDecoration judgeCardBoxDecorationSuccess() {
  return BoxDecoration(
      borderRadius: borderRadius1(),
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFF5D59FF),
          Color(0xFF7672FF),
        ],

      ));
}

BoxDecoration judgeCardBoxDecorationFail() {
  return BoxDecoration(
      borderRadius: borderRadius1(),
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFF1B2E57),
          Color(0xFF1B2E57),
        ],

      ));
}
