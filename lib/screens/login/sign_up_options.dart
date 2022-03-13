import 'package:dojo_app/screens/login/register.dart';
import 'package:dojo_app/screens/login/sign_in.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../widgets/host_card.dart';
import '../../style/colors.dart';

class SignUpOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void createAccountWithEmailButtonOnPress() {
      //Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: Register()));
      Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: Register()), (Route<dynamic> route) => false);
    }

    void signInButtonOnPress() {
      //Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: SignIn(existingUser: false,)));
      Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: SignIn(existingUser: false,)), (Route<dynamic> route) => false);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primarySolidBackgroundColor,
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
                    BackgroundOpacity(),
                    Column(
                      children: <Widget>[
                        SizedBox(
                          height: 16,
                        ),
                        Container(
                          height: 32,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/dojo_word_small_logo.png'),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 32,
                        ),
                        HostCard(
                          headLine: 'ACCESS DOJO',
                          bodyText:
                              'Choose your path',
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        HighEmphasisButton(
                          title: 'CREATE ACCOUNT WITH EMAIL',
                          onPressAction: createAccountWithEmailButtonOnPress,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Container(
                            decoration: BoxDecoration(
                                color: primaryTransparentCardColor,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(80)
                                )
                            ),
                          height: 42,
                          width: (MediaQuery.of(context).size.width) * .8,
                          child: LowEmphasisButton(
                            title: 'SIGN IN',
                            onPressAction: signInButtonOnPress,
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
    );
  }
}
