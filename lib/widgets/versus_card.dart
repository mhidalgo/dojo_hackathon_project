import 'package:dojo_app/screens/video_player/video_full_screen.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles.dart';
import 'package:dojo_app/widgets/circle_avatar.dart';
import 'package:flutter/cupertino.dart';

import '../style/colors.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:flutter/material.dart';

// versus cards have several different variations based on the state of that match
// NOTE: this is not an ideal implementation, rather,, this is a temporary solution until we can think of a new one

// uses 'cardType' to denote which flavor. As of now, only, type 5 is respected in the logic.

// 0 = default, do nothing special
// 1 = win / loss has been determined
// 2 = ACCEPT CHALLENGE state: this player has been challenged and needs to accept the challenge
// 3 = PENDING INVITE state: this player invited another player who still needs to join DOJO
// 4 = PENDING CHALLENGER state: this player is waiting on their challenger to perform the challenge
// 5 = ADD CHALLENGER state: no challenger has been invited to this challenge

class VersusCard2 extends StatelessWidget {
  VersusCard2({
    Key? key,
    this.cardType = 0, // not used
    this.titleVisibility = false,
    this.displayAcceptLevelButton = false,
    this.cardTitle = 'Pushup Challenge',
    this.cardSubTitle = '',
    this.cardOpacity = 0.75,

    // player 1
    required this.playerOneName,
    this.playerOneAvatar = 'images/avatar-blank.png',
    required this.playerOneScore,
    required this.playerOneVideo,

    // player 2
    required this.playerTwoName,
    this.playerTwoAvatar = 'images/avatar-blank.png',
    required this.playerTwoScore,
    required this.playerTwoVideo,
  }) : super(key: key);

  final bool titleVisibility;
  final bool displayAcceptLevelButton;

  final double cardOpacity;

  final int? cardType;
  final String cardTitle;
  final String cardSubTitle;

  final String playerOneName;
  final String playerOneAvatar;
  final String playerOneScore;
  final String playerOneVideo;
  final String playerTwoName;
  final String playerTwoAvatar;
  final String playerTwoScore;
  final String playerTwoVideo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width) * .90,
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: borderRadius1(),
        color: primarySolidCardColor.withOpacity(0.75),
      ),
      child: Column(
        children: [
          VersusCardTitle(
              titleVisibility: titleVisibility,
              cardTitle: cardTitle,
              cardSubTitle: cardSubTitle),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * .30,
                child: VersusCardPlayer(
                    playerName: playerOneName,
                    playerAvatar: playerOneAvatar,
                    playerVideo: playerOneVideo,
                    playerScore: playerOneScore,
                    cardType: cardType),
              ),
              Container(
                width: MediaQuery.of(context).size.width * .10,
                child: Column(
                  children: <Widget>[
                    BodyText1BoldItalic(text: 'VS.'),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * .30,
                child: VersusCardPlayer(
                    playerName: playerTwoName,
                    playerAvatar: playerTwoAvatar,
                    playerVideo: playerTwoVideo,
                    playerScore: playerTwoScore,
                    cardType: cardType),
              ),
            ],
          ),
          Visibility(
            visible: (displayAcceptLevelButton) ? true : false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 16),
                HighEmphasisButton(title: 'Accept Challenge')
              ],
            ),
          ),
          //SizedBox(height: 16),
        ],
      ),
    );
  }
}

class VersusCardTitle extends StatelessWidget {
  const VersusCardTitle({
    Key? key,
    required this.titleVisibility,
    required this.cardTitle,
    required this.cardSubTitle,
  }) : super(key: key);

  final bool titleVisibility;
  final String cardTitle;
  final String cardSubTitle;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: titleVisibility,
      child: Column(
        children: <Widget>[
          BodyText2BoldItalic(text: cardTitle),
          Text(
            cardSubTitle,
            style: Theme.of(context).textTheme.bodyText2,
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class VersusCardPlayer extends StatelessWidget {
  const VersusCardPlayer({
    Key? key,
    this.cardType,
    required this.playerName,
    required this.playerAvatar,
    this.playerVideo = '',
    required this.playerScore,
  }) : super(key: key);

  final int? cardType;
  final String playerName;
  final String playerAvatar;
  final String playerVideo;
  final String playerScore;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primarySolidCardColor.withOpacity(0.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Text(
                  playerName,
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          //avatarIcon(playerAvatar, cardType),
          CustomCircleAvatar(
            avatarImage: playerAvatar,
            radius: 32.0,
            avatarFirstLetter: playerName[0],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: (playerVideo != '') ? true : false,
                child: InkResponse(
                  highlightShape: BoxShape.circle,
                  splashColor: Colors.red,
                  highlightColor: Colors.red.withOpacity(0.5),
                  radius: 24,
                  onTap: () {
                    print('$playerVideo');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VideoFullScreen(
                                videoURL: playerVideo, videoConfiguration: 0,)));
                  },//The video URL is passed to the VideoFullScreen class
                  child: Icon(
                    Icons.play_arrow,
                    color: primaryDojoColor,
                    size: 24.0,
                  ),
                ),
              ),
              Text(
                playerScore,
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'POINTS',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}