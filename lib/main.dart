import 'package:dojo_app/models/dojo_user.dart';
import 'package:dojo_app/screens/matches_A2P/matches_wrapper.dart';
import 'package:dojo_app/screens/onboarding/start_screen.dart';
import 'package:dojo_app/screens/levels/levels_skeleton_screen.dart';
import 'package:dojo_app/screens/levels/levels_wrapper.dart';
import 'package:dojo_app/screens/login/nickname_page.dart';
import 'package:dojo_app/screens/menu/menu_screen.dart';
import 'package:dojo_app/screens/wrapper.dart';
import 'package:dojo_app/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:dojo_app/style/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'globals.dart' as globals;

void logError(String code, String? message) {
  if (message != null) {
    print('Error: $code\nError Message: $message');
  } else {
    print('Error: $code');
  }
}


void main() async {
  runZonedGuarded<Future<void>>(() async {

    ///Initialize Firebase services
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    ///Initialize Camera
    try {
      globals.cameras = await availableCameras();
      print(globals.cameras);
    } on CameraException catch (e) {
      logError(e.code, e.description);
    }

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    runApp(DojoApp());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class DojoApp extends StatelessWidget {

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);




  @override
  Widget build(BuildContext context) {
    return StreamProvider<DojoUser?>.value(
      initialData: null,
      value: AuthService().user,
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dojoTheme,
          //navigatorKey: globals.navigatorKey,
          initialRoute: '/',
          routes: {
            '/': (context) => Wrapper(),
            '/nickname': (context) => NicknamePage(),
            '/levels': (context) => LevelsSkeletonScreen(),
            '/menu': (context) => Menu(),
            '/loader': (context) => LevelsWrapper(),
            '/start': (context) => StartScreen(),
            'matches': (_) => MatchesWrapper()
          }),
    );
  }
}
