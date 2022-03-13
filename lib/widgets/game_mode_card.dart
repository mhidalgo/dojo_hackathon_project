import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles.dart';
import 'package:dojo_app/widgets/data_pill.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GameModeCard extends StatefulWidget {
  const GameModeCard({Key? key,
    required this.onPressAction,
    required this.subtitleIcon,
    required this.subtitle,
    required this.title,
    required this.description,
    this.icon2x = false,
    this.displayWinLossTieRecord = false,
  }) : super(key: key);

  final dynamic onPressAction;
  final IconData subtitleIcon;
  final String subtitle;
  final String title;
  final String description;
  final String dataBubbles = '';
  final bool icon2x;
  final bool displayWinLossTieRecord;


  @override
  _GameModeCardState createState() => _GameModeCardState();
}

class _GameModeCardState extends State<GameModeCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 8.0,
      borderOnForeground: false,
      child: Ink(
        height: 175,
        width: (MediaQuery.of(context).size.width)* .90,
        decoration: gameModeCardDecoration(),
        child: InkWell(
          splashColor: Colors.red,
          highlightColor: Colors.red.withOpacity(0.5),
          onTap: widget.onPressAction,
          child: Container(
            padding: EdgeInsets.all(24.0),
            child: Container(
              height: 175,
              width: (MediaQuery.of(context).size.width) * .90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                    child: Row(
                      children: [
                        (widget.icon2x) ? FaIcon(widget.subtitleIcon, size: 20, color: secondaryTextColor,) : Container(),
                        FaIcon(widget.subtitleIcon, size: 20, color: secondaryTextColor,),
                        SizedBox(width: 8),
                        Text('${widget.subtitle}',
                            style:
                            Theme.of(context).textTheme.caption),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      BodyText3BoldItalic(text: '${widget.title}'),
                    ],
                  ),
                  SizedBox(height: 4),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: BodyText2Italic(text: '${widget.description}'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              //padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.chevron_right, size: 32),
                            ),
                          ],
                        ),
                      ),
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

BoxDecoration gameModeCardDecoration() {
  return BoxDecoration(
      borderRadius: borderRadius1(),
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0x9900528E),
          Color(0x9922283D),
        ],

      ));
}