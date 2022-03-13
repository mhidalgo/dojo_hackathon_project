import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShortScoreTextField extends StatefulWidget {
  const ShortScoreTextField({
    Key? key,
    required this.inputLabel,
    this.onChangeAction,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  final String inputLabel;
  final onChangeAction; // a function
  final keyboardType;

  @override
  _ShortScoreTextFieldState createState() => _ShortScoreTextFieldState();
}

class _ShortScoreTextFieldState extends State<ShortScoreTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: MediaQuery.of(context).size.width * 0.30,
      child: TextField(
        onChanged: widget.onChangeAction,
        keyboardType: widget.keyboardType,
        style: TextStyle(
          fontSize: 42,
          height: 1.5,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          filled: true,
          //labelText: widget.inputLabel,
          //labelStyle: TextStyle(fontSize: 16, color: Colors.white),
          fillColor: Color(0x66161B30),
          //fillColor: Colors.white,
        ),
      ),
    );
  }
}

class ShortScoreTextFieldWithValidation extends StatelessWidget {
  const ShortScoreTextFieldWithValidation({
    Key? key,
    required this.validator,
    required this.onSaved,
    required this.inputLabel,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);


  final keyboardType;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final String inputLabel;



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: MediaQuery.of(context).size.width * 0.35,
      child: TextFormField(
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSaved: onSaved,
        validator: validator,
        keyboardType: keyboardType,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 42,
          height: 1.5,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0x66161B30),
          errorStyle: TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.black54
          ),
        ),
      ),
    );
  }
}



class CustomTextFieldRegistration extends StatelessWidget {
  CustomTextFieldRegistration({
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    required this.validator,
    required this.onSaved,
    required this.inputLabel,
  });

  final FormFieldSetter<String> onSaved;
  final String hint;
  final bool obscure;
  final FormFieldValidator<String> validator;
  final keyboardType;
  final String inputLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextFormField(
        obscureText: obscure,
        onSaved: onSaved,
        validator: validator,
        keyboardType: keyboardType,
        autofocus: true,
        decoration: InputDecoration(
          filled: true,
          hintText: hint,
          labelText: inputLabel,
          labelStyle: TextStyle(color: Colors.white),
          errorStyle: TextStyle(color: Colors.red),
          fillColor: Color(0x66161B30),
        ),
      ),
    );
  }
}

class RepsTextField extends StatelessWidget {
  const RepsTextField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          labelText: 'How many pushup repetitions?',
          //fillColor: Colors.white,
        ),
      ),
    );
  }
}
