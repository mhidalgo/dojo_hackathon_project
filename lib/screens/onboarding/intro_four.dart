import 'package:dojo_app/screens/login/sign_in.dart';
import 'package:dojo_app/screens/login/sign_up_options.dart';
import 'package:dojo_app/screens/onboarding/intro_five.dart';
import 'package:dojo_app/screens/video_player/video_full_screen.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';



class IntroScreenFour extends StatefulWidget {
  IntroScreenFour({Key? key,}) : super(key: key);

  @override
  _IntroScreenFourState createState() => _IntroScreenFourState();
}

class _IntroScreenFourState extends State<IntroScreenFour> {
  onPressAction() {
    print('tap');

    Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: SignIn(existingUser: false,)));

    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpOptions()),
    );*/
  }


  @override

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0x99161B30),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  tileMode: TileMode.mirror,
                  begin: Alignment.bottomLeft,
                  end: Alignment(0.1, -1.0),
                  colors: [
                    Color(0xff6d120c),
                    Color(0xff10064a),
                  ],
                  stops: [
                    0,
                    1,
                  ],
                ),
                backgroundBlendMode: BlendMode.saturation,
              ),
              child: PlasmaRenderer(
                type: PlasmaType.infinity,
                particles: 33,
                color: Color(0x6aff0004),
                blur: 0.4,
                size: 0.84,
                speed: 7,
                offset: 0,
                blendMode: BlendMode.screen,
                particleType: ParticleType.atlas,
                variation1: 0,
                variation2: 0,
                variation3: 0,
                rotation: 1.1,
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
                            VideoFullScreen(key: UniqueKey(), videoURL: 'https://firebasestorage.googleapis.com/v0/b/dojo-app-9812e.appspot.com/o/hackathon_videos%2Fmarvin-foul_shot.mp4?alt=media&token=84d0f461-6382-4d56-be63-f33242619f3a', videoConfiguration: 3),
                            //Opacity(opacity: 0.25, child: BackgroundTopImage(imageURL: 'images/castle.jpg')),
                            BackgroundOpacity(),
                            //BackgroundTopGradient(),
                            Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 64,
                                ),
                                Image.asset(
                                  'images/dojo_logo_1.png',
                                  height: 245.96,
                                  width: 236,
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                HostCard(
                                    headLineVisibility: false,
                                    bodyText: 'The judges who all set the same score win Dojo tokens.'),
                                //Center(child: CircularProgressIndicator()),
                                Container(
                                  height: 16,
                                ),
                                Container(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: HighEmphasisButtonWithAnimation(
                                      id: 1,
                                      title: 'LET\'S GO',
                                      onPressAction: onPressAction,
                                    ),
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
          )),
    );
  }
}
