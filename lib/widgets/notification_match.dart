import 'package:flutter/material.dart';
import 'package:dojo_app/style/colors.dart';

class NotificationMatch extends StatefulWidget {
  const NotificationMatch({Key? key, required this.message}) : super(key: key);

  final String message;

  @override
  _NotificationMatchState createState() => _NotificationMatchState();
}

class _NotificationMatchState extends State<NotificationMatch> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: secondaryColorDark1,
      alignment: Alignment.center,
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Image.asset('images/avatar-robot.png', height: 64, width:64),
          Text(widget.message),
        ],
      ),
    );
  }
}
