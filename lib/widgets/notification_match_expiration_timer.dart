import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dojo_app/style/colors.dart';

class NotificationMatchExpirationTimer extends StatefulWidget {
  const NotificationMatchExpirationTimer({Key? key, required this.expirationDateTime}) : super(key: key);

  final DateTime expirationDateTime;

  @override
  _NotificationMatchExpirationTimerState createState() => _NotificationMatchExpirationTimerState();
}

class _NotificationMatchExpirationTimerState extends State<NotificationMatchExpirationTimer> {
  late int year = widget.expirationDateTime.year;
  late int month = widget.expirationDateTime.month;
  late int day = widget.expirationDateTime.day;
  late int hour = widget.expirationDateTime.hour;
  late int minute = widget.expirationDateTime.minute;
  late int second = widget.expirationDateTime.second;
  late int estimateTs = DateTime(year, month, day, hour, minute, second).millisecondsSinceEpoch; // set needed date

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Stream.periodic(Duration(seconds: 1), (i) => i),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          DateFormat format = DateFormat("mm");
          DateFormat format2 = DateFormat("ss");
          int now = DateTime.now().millisecondsSinceEpoch;
          Duration remaining = Duration(milliseconds: estimateTs - now);
          var dateString = '${remaining.inHours}h ${format.format(DateTime.fromMillisecondsSinceEpoch(remaining.inMilliseconds))}m ${format2.format(DateTime.fromMillisecondsSinceEpoch(remaining.inMilliseconds))}s to complete the match';
          return Container(
            color: secondaryColorDark1,
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Image.asset('images/avatar-robot.png', height: 64, width:64),
                Text(dateString),
              ],
            ),
          );
        });
  }
}
