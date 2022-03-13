import 'package:dojo_app/screens/game_modes/game_modes_wrapper.dart';
import 'package:dojo_app/screens/onboarding/intro_five.dart';
import 'package:dojo_app/screens/onboarding/start_screen.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dojo_app/models/dojo_user.dart';
import 'package:dojo_app/globals.dart' as globals;

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {


  @override
  Widget build(BuildContext context) {
    //Collect user object and it's uid for future use
    final user = Provider.of<DojoUser?>(context);

    // store user object in globals file
    setGlobalUser(user);

    // return either the Home or Authenticate widget
    if (user == null) {
      return StartScreen();
    } else {
      // get from DB and set nickname in a global file
      printBig('wrapper, inside if statement', '${globals.dojoUser.uid}');
      // return GameModesWrapper();
      return IntroScreenFive();
    }
  }
}
