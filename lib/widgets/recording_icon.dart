import 'package:flutter/material.dart';

class RecordingIcon extends StatefulWidget{
  const RecordingIcon({
    Key? key,
  }) : super(key: key);

  @override
  _RecordingIconState createState() => _RecordingIconState();
}

class _RecordingIconState extends State<RecordingIcon> with SingleTickerProviderStateMixin{
  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController =
    new AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Icon(
          Icons.circle,
          color: Colors.red,
          size: 24,
        ),
      ),
    );
  }
}