import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/loading_icon.dart';
import 'package:flutter/material.dart';

class LoadingScreenStatic extends StatelessWidget {
  LoadingScreenStatic({Key? key, this.message = 'Loading...', this.displayVisual = 'loading icon'}) : super(key: key);

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
            color: primarySolidCardColor,
          ),
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
                              height: (MediaQuery.of(context).size.height) / 4,
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
        ));
  }
}
