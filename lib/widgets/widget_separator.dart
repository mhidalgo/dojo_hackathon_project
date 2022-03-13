import 'package:flutter/material.dart';

widgetSeparatorController(){

}

class WidgetSeparator extends StatelessWidget {
  const WidgetSeparator({
    Key? key, required this.axis, required this.size
  }) : super(key: key);

  final String axis; // horizontal or vertical
  final int size; // 1 = 8pt, 2 = 16pt, 3 = 24pt

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
    );
  }
}