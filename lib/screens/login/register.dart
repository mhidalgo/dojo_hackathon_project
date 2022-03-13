import 'package:dojo_app/screens/login/nickname_page.dart';
import 'package:dojo_app/screens/login/sign_up_options.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../widgets/host_card.dart';
import 'package:dojo_app/services/auth_service.dart';
import '../../style/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dojo_app/globals.dart' as globals;


class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  String errorMsg = '';
  String email = '';
  String password = '';
  bool isChecked = false;
  String nickname = 'Default';

  void emailInputFieldOnChange(value) {
    setState(() => email = value.trim());
    print('Email: $value');
  }

  void passwordInputFieldOnChange(value) {
    setState(() => password = value.trim());
    print('Password: $value');
  }

  void submitLoginInfo() async {
    final FormState? form = _formKey.currentState;
    if (_formKey.currentState!.validate() && isChecked == true) {
      form!.save();

      dynamic result = await _auth.registerWithEmailAndPassword(email, password, nickname, context);

      if (result != null) {
        _sendAnalyticsSignUpEvent();
        Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: NicknamePage()), (Route<dynamic> route) => false);
      } else {
        print('SOMETHING WENT WRONG');
      }
    } else if (isChecked == false) {
      final snackBar = SnackBar(
        content: Text('Terms and Conditions must be checked'),
        duration: const Duration(milliseconds: 5000),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  Future<void> _sendAnalyticsSignUpEvent() async {
    await globals.Analytics.analytics.logSignUp(signUpMethod: 'email'); //Google Analytics tracking
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
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
                                    bodyText: 'Provide your email address and create a password.',
                                    headLine: 'CREATE YOUR ACCOUNT',
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
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: borderRadius1(),
                                      ),
                                      child: CheckboxListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: borderRadius1(),
                                        ),
                                        title: RichText(
                                            text: TextSpan(children: [
                                              TextSpan(
                                              style: Theme.of(context).textTheme.bodyText2,
                                              text: "I agree to Dojo's "),
                                          TextSpan(
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                              text: "Terms of Service",
                                              recognizer: new TapGestureRecognizer()
                                                ..onTap = () async {
                                                  var url = "https://www.my-dojo.com/terms";
                                                  if (await canLaunch(url)) {
                                                    await launch(url, forceWebView: true);
                                                  } else {
                                                    throw 'Could not launch $url';
                                                  }
                                                }),
                                        ])),
                                        value: isChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isChecked = value!;
                                          });
                                        },
                                        activeColor: Color(0xffe80911),
                                        tileColor: Color(0xFF161B30),
                                        controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  HighEmphasisButton(
                                    title: 'CREATE MY ACCOUNT',
                                    onPressAction: submitLoginInfo,
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
        ));
  }
}

String? emailValidator(String? value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);

  var trimmedValue = value!.trim(); //trims input

  if (trimmedValue.isEmpty) return '*Required';
  if (!regex.hasMatch(trimmedValue))
    return '*Enter a valid email';
  else
    return null;
}

String? isPasswordValid(String? password) {
  if (password!.length < 6) {
    return 'Must be at least 6 characters';
  } else {
    return null;
  }
}
