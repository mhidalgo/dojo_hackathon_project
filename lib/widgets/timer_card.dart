import 'package:dojo_app/style/text_styles.dart';
import 'package:flutter/material.dart';
import '../style/colors.dart';

class TimerCard extends StatefulWidget {
  const TimerCard({
    Key? key, required this.timer, this.size = 'average'
  }) : super(key: key);

  final int timer;
  final String size;

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // default font size is 100
    Widget timerTextWidget = BodyTextCustomSizeBold(text: '${widget.timer}');

    void setTimerSize() {
      if (widget.size == 'small') {
        timerTextWidget = BodyTextCustomSizeBold(text: '${widget.timer}', fontSize: 40);
      }
    }

    // set configurations for the timer card
    setTimerSize();

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              //height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(6),
                ),
                color: primarySolidCardColor.withOpacity(0.7),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
                child: Container(
                  child: Column(
                    children: [
                      Text('WORKOUT TIMER', textAlign: TextAlign.center,style: Theme.of(context).textTheme.caption,),
                      timerTextWidget,
                      //Text('$timer', textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline1,),
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