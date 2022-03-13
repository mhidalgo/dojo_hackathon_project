import 'package:dojo_app/style/colors.dart';
import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatelessWidget {
  CustomCircleAvatar(
      {this.avatarFirstLetter = 'X',
      this.radius = 25.0,
      this.avatarImage = 'https://firebasestorage.googleapis.com/v0/b/dojo-app-9812e.appspot.com/o/assets_app%2Fimages%2FDojo-Player-Avatar-Kora.png?alt=media&token=90640f1b-136f-4708-a43e-6cc01fdda822',
      this.enableAvatarImage = false});

  final String avatarFirstLetter;
  final double radius;
  final String avatarImage;
  final bool enableAvatarImage;

  @override
  Widget build(BuildContext context) {
    Widget avatarAsLetter;
    TextStyle? avatarLetterStyle;
    if (radius < 16.0) {
      avatarLetterStyle = Theme.of(context).textTheme.caption;
    } else if (radius < 25) {
      avatarLetterStyle = Theme.of(context).textTheme.bodyText1;
    } else
      avatarLetterStyle = Theme.of(context).textTheme.headline3;

    if (enableAvatarImage == true) {
      return CircleAvatar(
        radius: radius,
        //backgroundImage: AssetImage(avatarImage),
        backgroundImage: NetworkImage(avatarImage),
        backgroundColor: primaryDojoColorLighter,
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: primaryDojoColorLighter,
        child: Text(avatarFirstLetter.toUpperCase(), style: avatarLetterStyle),
      );
    }


  }
}
