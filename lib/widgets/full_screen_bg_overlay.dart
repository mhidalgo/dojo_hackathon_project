import 'package:flutter/material.dart';
import '../style/colors.dart';

class FullScreenBackgroundOverlay extends StatelessWidget {
  const FullScreenBackgroundOverlay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primarySolidBackgroundColor.withOpacity(0.75),
    );
  }
}