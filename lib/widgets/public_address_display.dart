import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles.dart';
import 'package:flutter/material.dart';

class DisplayPublicAddress extends StatelessWidget {
  const DisplayPublicAddress({Key? key, required this.address, this.title='Pay this Ethereum address'}) : super(key: key);

  final String address;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        //color: primarySolidCardColor,
        color: primaryTransparentCardColor,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(visible: true, child: BodyText1BoldItalic(text: title)),
              SizedBox(height: 16),
              Row(
                children: [
                  Container(alignment: Alignment.center, child: BodyText2Italic(text: address)),
                  SizedBox(width:20),
                  Icon(Icons.copy, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
