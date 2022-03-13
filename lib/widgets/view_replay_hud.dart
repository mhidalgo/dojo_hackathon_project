import 'package:dojo_app/style/text_styles.dart';
import 'package:flutter/material.dart';
import '../style/colors.dart';

class ViewReplayHud extends StatefulWidget {
  const ViewReplayHud({
    Key? key, required this.timer, this.playerOneNickname = 'Player One', this.playerTwoNickname = "Player Two",
  }) : super(key: key);

  final int timer;
  final String playerOneNickname;
  final String playerTwoNickname;

  @override
  State<ViewReplayHud> createState() => _ViewReplayHudState();
}

class _ViewReplayHudState extends State<ViewReplayHud> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget timerTextWidget = BodyTextCustomSizeBold(text: '${widget.timer}', fontSize: 32);

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: primarySolidCardColor.withOpacity(0.7),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.arrow_drop_down),
                                Text('${widget.playerOneNickname}', textAlign: TextAlign.center,style: Theme.of(context).textTheme.caption,),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text('WORKOUT TIMER', textAlign: TextAlign.center,style: Theme.of(context).textTheme.caption,),
                          ],
                        ),
                      ),
                      timerTextWidget,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}