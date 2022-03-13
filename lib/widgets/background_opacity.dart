import 'package:flutter/material.dart';

class BackgroundOpacity extends StatelessWidget {
  BackgroundOpacity({
    Key? key, this.opacity = 'low'
  }) : super(key: key);

  final String opacity;
  late final Color opacityColor;



  @override
  Widget build(BuildContext context) {
    if (opacity == 'low') {
      opacityColor = Color(0x66161B30);
    } else if (opacity == 'medium') {
      opacityColor = Color(0x8C161B30);
    } else if (opacity == 'high') {
      opacityColor = Color(0xCC161B30);
    } else {
      // fully opaque
      opacityColor = Color(0x00161B30);
    }

    return Container(
      decoration: BoxDecoration(
        color: opacityColor,
      ),
    );
  }
}