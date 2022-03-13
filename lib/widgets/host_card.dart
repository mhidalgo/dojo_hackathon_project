import 'package:flutter/material.dart';
import '../style/colors.dart';
import '../style/text_styles.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HostCard extends StatelessWidget {
  HostCard(
      {this.headLine = '',
      required this.bodyText,
      this.headLineVisibility = true,
      this.transparency = false,
      this.loud = false,
      this.variation = 1});

  final String headLine;
  final String bodyText;
  final bool headLineVisibility;
  final bool transparency;
  final bool loud;
  final int variation;

  @override
  Widget build(BuildContext context) {
    final Widget bodyTextToDisplay;


    if (loud == true || variation == 2) {
      // host card for GameScreen() countdown
      // has larger text
      bodyTextToDisplay = Container(
          alignment: Alignment.center, child: BodyText6Bold(text: '$bodyText'));
    } else if (variation == 3) {
      // host card for ViewReplayScreen()'s countdown
      // has smaller text
      bodyTextToDisplay = Container(
          alignment: Alignment.center, child: BodyText5Bold(text: '$bodyText'));
    } else {
      // host card for most scenarios
      // regular title and body size
      // has animation
      bodyTextToDisplay = AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            bodyText,
            textStyle: Theme.of(context).textTheme.bodyText2,
            speed: const Duration(milliseconds: 25),
          ),
        ],

        totalRepeatCount: 1,
        pause: const Duration(milliseconds: 1000),
        displayFullTextOnTap: true,
        stopPauseOnTap: true,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('images/avatar-host-Sensei.png'),
          ),
          SizedBox(
            width: 16,
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Material(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                //color: primarySolidCardColor,
                color: transparency
                    ? primaryTransparentCardColor
                    : primarySolidCardColor,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                          visible: headLineVisibility,
                          child: BodyText1BoldItalic(text: '$headLine')),
                      SizedBox(height: 8),
                      bodyTextToDisplay,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
