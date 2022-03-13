import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';


class RateFormQuestions extends StatefulWidget {
  const RateFormQuestions({Key? key,
    required this.title,
    required this.question,
    required this.playerUserID,
    required this.answerOptions,
    required this.saveButtonAction,
    required this.questionIndex,}) : super(key: key);

  final String title;
  final String question;
  final String playerUserID;
  final List answerOptions;
  final saveButtonAction;
  final int questionIndex;

  @override
  _RateFormQuestionsState createState() => _RateFormQuestionsState();
}

class _RateFormQuestionsState extends State<RateFormQuestions> {
  @override
  void initState() {
    super.initState();
  }

  submitRating(answer) {
    widget.saveButtonAction(widget.playerUserID, widget.questionIndex, answer);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HostCard(
          headLine: widget.title,
          bodyText: widget.question,
          transparency: true,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            EmojiButton(
              emoji: '😄',
              onPressAction: () => submitRating(3)),
            EmojiButton(
              emoji: '😐',
              onPressAction: () => submitRating(2)),
            EmojiButton(
              emoji: '😞',
              onPressAction: () => submitRating(1)),
          ],
        ),
      ],
    );
  }
}


