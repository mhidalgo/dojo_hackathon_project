import 'package:dojo_app/screens/onboarding/intro_five.dart';
import 'package:dojo_app/screens/onboarding/intro_one.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../widgets/host_card.dart';
import 'package:dojo_app/services/auth_service.dart';
import '../../style/colors.dart';
import '../wrapper.dart';
import 'package:dojo_app/screens/login/sign_up_options.dart';
import 'package:dojo_app/globals.dart' as globals;

class SignIn extends StatefulWidget {

  SignIn({required this.existingUser});

  //This variable gets passed into auth method to check if their is existing user.
  final bool existingUser;

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {


  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String headline = '';


  void emailInputFieldOnChange(value) {
    setState(() => email = value.trim());
    print('Email: $value');
  }

  void passwordInputFieldOnChange(value) {
    setState(() => password = value.trim());
    print('Password: $value');
  }

  void submitSignInFromOnPress() async {
    final FormState? form = _formKey.currentState;

    if (_formKey.currentState!.validate()) {
      form!.save();

      dynamic result = await _auth.signInWithEmailAndPassword(email, password, context);

      if (result != null) {
        _sendAnalyticsLoginEvent();
        Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.topToBottom, child: Wrapper()), (Route<dynamic> route) => false);


        //Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.topToBottom, child: Wrapper()));
        //Navigator.popUntil(context, ModalRoute.withName('/'));
        //Navigator.of(context).popUntil((route) => route.isFirst);
        //Navigator.pop(context);
        //Navigator.pop(context);
      }
    }
  }

  void backButtonAction() {
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: SignUpOptions()), (Route<dynamic> route) => false);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Google Analytic Tracking Methods
  /// ***********************************************************************
  /// ***********************************************************************

  Future<void> _sendAnalyticsLoginEvent() async {
    await globals.Analytics.analytics.logLogin(); //Google Analytics tracking
  }



  @override
  void initState() {
    if(widget.existingUser == true)
      {
        headline = "YOU'VE ALREADY SIGNED UP";
      }
    else {
      headline = 'SIGN IN';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: primarySolidBackgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
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
                      BackgroundOpacity(opacity: 'high'),
                      Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: () {
                                  print('tap');
                                  backButtonAction();
                                },
                              ),
                            ],
                          ),
                          Form(
                            key: _formKey,
                            autovalidateMode: AutovalidateMode.always,
                            child: Column(
                              children: <Widget>[
                                HostCard(
                                  bodyText:
                                      'Provide your email address and password to access DOJO.',
                                  headLine: headline,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                CustomTextFieldRegistration(
                                    inputLabel: 'Email Address',
                                    hint: '',
                                    onSaved: emailInputFieldOnChange,
                                    validator: emailValidator,
                                    keyboardType: TextInputType.emailAddress),
                                CustomTextFieldRegistration(
                                    inputLabel: 'Password',
                                    hint: '',
                                    onSaved: passwordInputFieldOnChange,
                                    validator: isPasswordValid,
                                    keyboardType: TextInputType.visiblePassword),
                                SizedBox(
                                  height: 16,
                                ),
                                MediumEmphasisButton(
                                  title: 'SIGN IN',
                                  onPressAction: submitSignInFromOnPress,
                                ),
                              ],
                            ),
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
      ),
    );
  }
}


///Checks if email is valid format and trim any trailing space
String? emailValidator(String? value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);

  var trimmedValue = value!.trim();  //trims input

  if (trimmedValue.isEmpty) return '*Required';
  if (!regex.hasMatch(trimmedValue))
    return '*Enter a valid email';
  else
    return null;
}


///Checks if password is at least 6 characters
String? isPasswordValid(String? password) {
  if (password!.length < 6) {
    return 'Must be at least 6 characters';
  } else {
    return null;
  }
}
