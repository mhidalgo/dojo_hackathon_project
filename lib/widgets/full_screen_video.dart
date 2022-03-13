import 'package:flutter/material.dart';

class FullScreenVideo extends StatefulWidget {
  const FullScreenVideo({Key? key}) : super(key: key);

  @override
  _FullScreenVideoState createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(color: Colors.red),
        ),
      ),
    ]);
  }
}
