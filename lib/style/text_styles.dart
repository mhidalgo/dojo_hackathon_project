import 'package:dojo_app/style/colors.dart';
import 'package:flutter/material.dart';

/// Text theme reference
/// Locate in style/theme.dart
// Text('Headline1', style: Theme.of(context).textTheme.headline1), --> 108px (unused)
// Text('Headline2', style: Theme.of(context).textTheme.headline2), --> 80px (unused)
// Text('Headline3', style: Theme.of(context).textTheme.headline3), --> 36px
// Text('Headline4', style: Theme.of(context).textTheme.headline4),--> 20px
// Text('Headline5', style: Theme.of(context).textTheme.headline5), --> 18px offwhite
// Text('Headline6', style: Theme.of(context).textTheme.headline6), --> 18px offwhite bold
// Text('BodyText1: 18px regular', style: Theme.of(context).textTheme.bodyText1), --> 18px
// Text('BodyText2: 16px regular', style: Theme.of(context).textTheme.bodyText2), --> 16px
// Text('Caption: 14px regular, CAPS', style: Theme.of(context).textTheme.caption) --> 15px

/// Custom text theme references
/// The Text widgets are in this file, below

/// 18pt Font
// BodyText1Bold(text: 'BodyText1Bold: 18 Bold'), --> 18px bold
// BodyText1BoldItalic('BodyText1: 18 Bold Italic'), --> 18px bold italic
// BodyText1WhiteButton(text: 'BodyText1WhiteButton: 18 Regular Black'), --> 18px

/// 16pt Font
// BodyText2Bold('BodyText2: 16 Bold'), --> 16px Bold
// BodyText2BoldItalic('BodyText2BoldItalic: 16 Bold and Italic'), --> 16px Bold Italic
// BodyText2Italic('BodyText2BoldItalic: 16 Italic'), --> 16px Italic

/// Misc font sizes
// BodyText3BoldItalic(text: 'BodyText3: 24 Bold Italic'), --> 24px bold italic
// BodyText4(text: 'BodyText4: 12px offwhite'), --> 12px offwhite
// BodyText5Bold(text: 'BodyText5Bold: 48 Bold'), --> 48 Bold
// BodyTextCustomSizeBold(text:'BodyTextCustomSizeBold: Bold', size: 100.0), --> 100 Bold
// BodyText6(text: 'BodyText6: 12px white'), --> 12px white


class BodyText1WhiteButton extends StatelessWidget {
  const BodyText1WhiteButton({
    Key? key, this.text = 'BodyText1WhiteButton: Regular',
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
          fontStyle: FontStyle.italic,
        color: Color(0xFF000000)
      ),
    );
  }
}

class BodyText1Bold extends StatelessWidget {
  const BodyText1Bold({
    Key? key, this.text = 'BodyText1: Bold',
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class BodyText1BoldItalic extends StatelessWidget {
  const BodyText1BoldItalic({
    Key? key, this.text = 'BodyText1: Bold and Italic',
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class BodyText2Italic extends StatelessWidget {
  const BodyText2Italic({
    Key? key, this.text = 'BodyText2: Italic',
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class BodyText2BoldItalic extends StatelessWidget {
  const BodyText2BoldItalic({
    Key? key, this.text = 'BodyText2: Bold and Italic',
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class BodyText2Bold extends StatelessWidget {
  const BodyText2Bold({
    Key? key, this.text = 'BodyText2: Bold',
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class BodyText3BoldItalic extends StatelessWidget {
  const BodyText3BoldItalic({
    Key? key, this.text = 'BodyText3: Bold and Italic 24px',
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class BodyText4 extends StatelessWidget {
  const BodyText4({
    Key? key, this.text = 'BodyText4: 12px offwhite',
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: offWhiteColor,
      ),
    );
  }
}

class BodyText6 extends StatelessWidget {
  const BodyText6({
    Key? key, this.text = 'BodyText4: 12px white',
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: Colors.white,
      ),
    );
  }
}

class BodyText5Bold extends StatelessWidget {
  const BodyText5Bold({
    Key? key, this.text = 'BodyTextLarge: 48 Bold', this.fontColor = const Color(0xFFFFFFFF),
  }) : super(key: key);

  final String text;
  final Color fontColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: fontColor,
      ),
    );
  }
}

class BodyText6Bold extends StatelessWidget {
  const BodyText6Bold({
    Key? key, this.text = 'BodyText6: Bold',
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 80,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class BodyTextCustomSizeBold extends StatelessWidget {
  const BodyTextCustomSizeBold({
    Key? key, this.text = 'BodyTetCustom: Bold', this.fontSize = 100.0,
  }) : super(key: key);

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class EmojiText extends StatelessWidget {
  const EmojiText({
    Key? key, this.emoji = '😄',
  }) : super(key: key);

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.normal,
          color: Color(0xFFFFFFFF),
      ),
    );
  }
}