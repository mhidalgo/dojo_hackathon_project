import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingAnimatedIcon extends StatelessWidget {
  const LoadingAnimatedIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(
      color: Colors.blue,
      size: 50.0,
    );
  }
}
