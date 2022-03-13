import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles.dart';
import 'package:flutter/material.dart';

class DataPill extends StatelessWidget {
  const DataPill({Key? key, this.data = 'Data: 0'}) : super(key: key);

  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: primaryColorDark1,
        borderRadius: roundCornersRadius(),
      ),
      child: BodyText4(text: '$data'),
      //Text('  Personal Record: $personalRecord  ', style: Theme.of(context).textTheme.caption)
    );
  }
}
