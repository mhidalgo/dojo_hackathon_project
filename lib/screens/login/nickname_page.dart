import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../widgets/host_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../style/colors.dart';
import '../wrapper.dart';


class NicknamePage extends StatefulWidget {
  const NicknamePage({Key? key}) : super(key: key);

  @override
  _NicknamePageState createState() => _NicknamePageState();
}

class _NicknamePageState extends State<NicknamePage> {
  String nickname = '';
  final _formKey = GlobalKey<FormState>();
  late String userID = FirebaseAuth.instance.currentUser!.uid;
  late CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> submitUserProfileData() async {

    final FormState? form = _formKey.currentState;

    if(_formKey.currentState!.validate()) {
      form!.save();
      return users
          .doc(userID)
          .update({'Nickname': nickname})
          .then(
              (value) =>
                  Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.topToBottom, alignment: Alignment.bottomCenter, child: Wrapper()))
      )
          .catchError((error) => print("Failed to update user: $error"));

    }
  }



  void nicknameInputFieldOnChange(value) {
    setState(() => nickname = value.trim());
    print('Nickname: $value');
  }

  void backButtonAction() {
    Navigator.pop(context, []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primarySolidBackgroundColor,
      /*appBar: AppBar(
        backgroundColor: primarySolidBackgroundColor,
        centerTitle: true,
      ),*/
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: (MediaQuery.of(context).size.height) -
                    (MediaQuery.of(context).padding).top -
                    (MediaQuery.of(context).padding).bottom,
                child: Stack(
                  children: <Widget>[
                    BackgroundTopImage(imageURL: 'images/castle.jpg'),
                    //BackgroundTopGradient(opacity: 0.2, stopStart: 0.2, stopEnd: 0.65),
                    BackgroundOpacity(opacity: 'high'),
                    Column(
                      children: <Widget>[
                        SizedBox(
                          height: 16,
                        ),
                        HostCard(
                          bodyText: 'A good nickname will help your opponents understand your competitive personality.',
                          headLine: 'NICKNAME',
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Form(
                          key: _formKey,
                          child: CustomTextFieldRegistration(
                              inputLabel: 'Provide a nickname',
                              hint: 'What can I call you?',
                              onSaved: nicknameInputFieldOnChange,
                              validator: nicknameValidator,
                              keyboardType: TextInputType.text),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        MediumEmphasisButton(
                          title: 'Next',
                          onPressAction: submitUserProfileData,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? nicknameValidator(String? value) {
  if (value!.isEmpty) return '*Required';
  if (value.length < 1) {
    return 'Must provide a nickname to play!';
  }
  else if(value.length > 20) {
    return 'Nickname is too long';
  }
  else{
    return null;
  }
}