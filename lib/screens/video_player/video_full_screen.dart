import 'dart:async';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/screens/video_player/video_fullscreen_player.dart';


class VideoFullScreen extends StatefulWidget {
  VideoFullScreen({Key? key,
    this.videoMap = const {},
    required this.videoURL,
    required this.videoConfiguration,})
      : super(key: key);

  final Map videoMap; // contains local video file
  final dynamic videoURL; // contains firebase video URL
  final int videoConfiguration;

  @override
  _VideoFullScreenState createState() => _VideoFullScreenState();
}

class _VideoFullScreenState extends State<VideoFullScreen> {
  late VideoPlayerController controller;

  // get passed in variables
  late final String videoURL = widget.videoURL;
  late final int videoConfiguration = widget.videoConfiguration;

  @override
  void initState() {
    super.initState();

    /// Create video controller with specified settings
    if (videoConfiguration == 0) {
      // no loop, has sound, has player controls, firestore url played
      // usage: full page player accessed from versusCard
      controller = VideoPlayerController.network(videoURL)
        ..addListener(() => setState(() {}))
        ..initialize().then((_) => controller.play());
    } else if (videoConfiguration == 1) {
      // has loop, no sound, no player controls
      // local file played
      // usage: in game post xp to play back their own video
      controller = VideoPlayerController.file(widget.videoMap['localVideoFile'])
        ..addListener(() => setState(() {}))
        ..setLooping(true)
        .. setVolume(0.0)
        ..initialize().then((_) => controller.play());
    } else if (videoConfiguration == 2) {
      // has no loop, no sound, no player controls
      // plays firebase url, limited to first 12 seconds
      controller = VideoPlayerController.network(videoURL)
        ..addListener(() => setState(() {}))
        ..initialize().then((_) {
          controller.play();
          Timer(Duration(seconds: 12), () {
            controller.pause();
          });
        });
    } else if (videoConfiguration == 3) {
      // has loop, no sound, no player controls
      // plays firebase url, limited to first 12 seconds
      controller = VideoPlayerController.network(videoURL)
        ..addListener(() => setState(() {}))
        ..initialize().then((_) {
          controller.play();
          Timer(Duration(seconds: 24), () {
            controller.pause();
          });
        });
    } else if (videoConfiguration == 4) {
      // has no loop, has sound, no player controls
      // plays firebase url, limited to first 25 seconds
      // usage: match screen plays this in the background
      controller = VideoPlayerController.network(videoURL)
        ..addListener(() => setState(() {}))
        ..initialize().then((_) {
          controller.play();
          Timer(Duration(seconds: 25), () {
            controller.pause();
          });
        });
    }

  }

  @override
  void dispose() {
    controller.dispose();
    printBig('video player DISPOSED in video class', 'true');
    super.dispose();
  }

  backButtonAction() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    /// Returns the Video Player Widget with the additional play controls and a back button.
    if (videoConfiguration == 0) {
      return Stack(children: <Widget>[
        VideoPlayerFullscreenWidget(controller: controller, videoConfiguration: videoConfiguration),
        Positioned(
          top: 40,
          left: 40,
          child: Material(
            child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  print('tap');
                  backButtonAction();
                }),
          ),
        ),
      ]);
    }
    /// Returns the Video Player Widget without playback controls and back button.
    // videoConfiguration = 1 or 2 or 4
    else {
      return VideoPlayerFullscreenWidget(
          controller: controller, videoConfiguration: videoConfiguration);
    }
  }
}
