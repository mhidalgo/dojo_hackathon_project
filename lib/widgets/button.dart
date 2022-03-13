import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles.dart';
import 'package:flutter/material.dart';
import '../style/colors.dart';

double buttonOpacityFull = 1;
double buttonOpacityHalf = 0.5;

class HighEmphasisButton extends StatelessWidget {
  const HighEmphasisButton({
    Key? key,
    this.id = 0,
    required this.title,
    this.primaryColor = primaryDojoColor,
    this.onPrimaryColor = Colors.white,
    this.onPressAction,
  }) : super(key: key);

  final int id;
  final String title;
  final Color primaryColor;
  final Color onPrimaryColor;
  final onPressAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width) * 0.80,
      height: 48,
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: Offset(5, 5),
          ),
        ],
          borderRadius: BorderRadius.all(
              Radius.circular(80)
          )
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: primaryColor, // background
          onPrimary: onPrimaryColor, // foreground
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80.0)),
        ),
        onPressed: onPressAction,
        child: BodyText1BoldItalic(text: title),
      ),
    );
  }
}

class HighEmphasisButtonWithAnimation extends StatefulWidget {
  const HighEmphasisButtonWithAnimation({
    Key? key,
    this.id = 0,
    required this.title,
    this.primaryColor = primaryDojoColor,
    this.onPrimaryColor = Colors.white,
    this.onPressAction,
  }) : super(key: key);

  final int id;
  final String title;
  final Color primaryColor;
  final Color onPrimaryColor;
  final onPressAction;

  @override
  _HighEmphasisButtonWithAnimationState createState() => _HighEmphasisButtonWithAnimationState();
}

class _HighEmphasisButtonWithAnimationState extends State<HighEmphasisButtonWithAnimation> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this, value: 0.0);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: (MediaQuery.of(context).size.width) * 0.80,
        height: 48,
        decoration: BoxDecoration(
            boxShadow: <BoxShadow>[boxShadow1(),],
            borderRadius: BorderRadius.all(
                Radius.circular(80)
            )
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: widget.primaryColor, // background
            onPrimary: widget.onPrimaryColor, // foreground
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80.0)),
          ),
          onPressed: widget.onPressAction,
          child: BodyText1BoldItalic(text: widget.title),
        ),
      ),
    );
  }
}

class MediumEmphasisButton extends StatelessWidget {
  const MediumEmphasisButton({
    Key? key,
    this.id = 0,
    required this.title,
    this.primaryColor = Colors.white,
    this.onPrimaryColor = Colors.black,
    this.onPressAction,
  }) : super(key: key);

  final int id;
  final String title;
  final Color primaryColor;
  final Color onPrimaryColor;
  final onPressAction; // a function

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width) * 0.80,
      height: 48,
      decoration: BoxDecoration(
          boxShadow: <BoxShadow>[boxShadow1(),],
          borderRadius: BorderRadius.all(
              Radius.circular(80)
          )
      ),
      child: OutlinedButton(
        style: ElevatedButton.styleFrom(
          primary: primaryColor, // background
          onPrimary: onPrimaryColor, // foreground
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80.0)),
        ),
        onPressed: onPressAction,
        child: BodyText1WhiteButton(text: title),
      ),
    );
  }
}

class LowEmphasisButton extends StatelessWidget {
  const LowEmphasisButton({
    Key? key,
    this.id = 0,
    required this.title,
    this.onPressAction,
  }) : super(key: key);

  final int id;
  final String title;
  final onPressAction;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressAction,
      child: Text('SIGN IN', style: Theme.of(context).textTheme.bodyText2),
    );
  }
}

class LowEmphasisButtonWithBorder extends StatelessWidget {
  const LowEmphasisButtonWithBorder({
    Key? key,
    this.id = 0,
    required this.title,
    this.onPressAction,
    this.buttonColor = onPrimaryBlack,
    this.buttonEnabled = true,
  }) : super(key: key);

  final int id;
  final String title;
  final onPressAction;
  final Color buttonColor;
  final bool buttonEnabled;

  @override
  Widget build(BuildContext context) {
    double opacity = buttonOpacityFull;
    if (buttonEnabled == false) {
      opacity = buttonOpacityHalf;
    }

    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.all(
                Radius.circular(80)
            )
        ),
        height: 42,
        width: (MediaQuery.of(context).size.width) * .8,
        child: TextButton(
          onPressed: onPressAction,
          child: Text('$title', style: Theme.of(context).textTheme.bodyText2),
        ),
      ),
    );
  }
}

class EmojiButton extends StatelessWidget {
  const EmojiButton({
    Key? key,
    this.id = 0,
    required this.emoji,
    this.primaryColor = Colors.white,
    this.onPrimaryColor = Colors.black,
    this.onPressAction,
  }) : super(key: key);

  final int id;
  final String emoji;
  final Color primaryColor;
  final Color onPrimaryColor;
  final onPressAction; // a function

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 48,
      decoration: BoxDecoration(
          boxShadow: <BoxShadow>[boxShadow1(),],
          borderRadius: BorderRadius.all(
              Radius.circular(80)
          )
      ),
      child: OutlinedButton(
        style: ElevatedButton.styleFrom(
          primary: primaryColor.withOpacity(0.3), // background
          onPrimary: onPrimaryColor.withOpacity(0.8), // foreground
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80.0)),
        ),
        onPressed: onPressAction,
        child: EmojiText(emoji: emoji),
      ),
    );
  }
}



