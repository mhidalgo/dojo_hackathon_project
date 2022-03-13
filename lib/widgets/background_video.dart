import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

//Took out background image, but ended up not needing this class for now.

class BackgroundVideo extends StatelessWidget {
  BackgroundVideo({Key? key, required this.controller}) : super(key: key);

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CameraPreview(controller),
    );
  }
}
