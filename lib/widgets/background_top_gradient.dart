import 'package:flutter/material.dart';

class BackgroundTopGradient extends StatelessWidget {
  const BackgroundTopGradient({
    Key? key, this.opacity = 0.5, this.stopStart = 0.0, this.stopEnd = 0.75
  }) : super(key: key);

  final double opacity;
  final double stopStart;
  final double stopEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF161B30).withOpacity(opacity),
            Color(0xFF161B30),
          ],
          stops: [stopStart, stopEnd],
        ),
      ),
    );
  }
}