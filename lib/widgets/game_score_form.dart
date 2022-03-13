import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';


class GameScoreForm extends StatefulWidget {
  const GameScoreForm({Key? key,

    // TextField Data
    required this.inputLabel,
    this.saveScoreInputFieldAction,
    this.keyboardType,

    // Button Data
    required this.title,
    this.saveScoreButtonAction,

  }) : super(key: key);

  // TextField Data
  final String inputLabel;
  final saveScoreInputFieldAction;
  final keyboardType;

  // Button Data
  final String title;
  final saveScoreButtonAction;

  @override
  _GameScoreFormState createState() => _GameScoreFormState();
}

class _GameScoreFormState extends State<GameScoreForm> {
  final _formKey = GlobalKey<FormState>();
  String score = '';

  void scoreInputFieldOnChange(value) {
    setState(() => score = value.trim());
    widget.saveScoreInputFieldAction(value);
    print('Score: $value');
  }

  void submitGameScore() {
    final FormState? form = _formKey.currentState;

    if (_formKey.currentState!.validate()) {
      form!.save();
      widget.saveScoreButtonAction();

    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          children: <Widget>[
            ShortScoreTextFieldWithValidation(
                inputLabel: widget.inputLabel,
                onSaved: scoreInputFieldOnChange,
                validator: scoreValidator,
                keyboardType: TextInputType.number,
            ),
            MediumEmphasisButton(
                title: widget.title,
                onPressAction: submitGameScore,
            )
          ],
        ));
  }
}

///Form Validation checks
String? scoreValidator(String? value) {

  var trimmedValue = value!.trim();  //trims input

  if(trimmedValue.length > 3) {
    return "Too Big!";
  }

  if(trimmedValue.length > 0) {
    var parsedValue = int.parse(trimmedValue);
    if (parsedValue > 200) {
      return 'No Way';
    }
  }

  if (trimmedValue.isEmpty) return 'Required';
  else
    return null;
}