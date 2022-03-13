import 'package:dojo_app/widgets/loading_icon.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class LoadingScreen extends StatelessWidget {
  LoadingScreen({Key? key, this.message = '', this.displayVisual = 'nothing'}) : super(key: key);

  final String message;
  final String displayVisual;

  @override
  Widget build(BuildContext context) {
    /// Manage what is displayed on the loading page
    Widget displayThisVisual = Container();
    if (displayVisual == 'loading icon') {
      displayThisVisual = LoadingAnimatedIcon();
    } else if (displayVisual == 'dojo logo') {
      displayThisVisual = Image.asset(
        'images/dojo_logo_1.png',
        height: 245.96,
        width: 236,
      );
    }

    return SafeArea(
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: (MediaQuery.of(context).size.height) -
                        (MediaQuery.of(context).padding).top -
                        (MediaQuery.of(context).padding).bottom,
                    child: Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            SizedBox(
                              height: 16,
                            ),
                            SizedBox(
                              height: (MediaQuery.of(context).size.height) / 2.25,
                            ),
                            Column(
                              children: [
                                displayThisVisual,
                                Text(message, style: Theme.of(context).textTheme.bodyText1),
                              ],
                            ),
                            Container(
                              height: 16,
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
      ),
    ));
  }
}
