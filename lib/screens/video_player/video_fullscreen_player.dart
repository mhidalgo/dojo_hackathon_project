import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// ***************************************************
/// Video Player Widget
/// ***************************************************

class VideoPlayerFullscreenWidget extends StatelessWidget {
  const VideoPlayerFullscreenWidget(
      {Key? key, required this.controller, required this.videoConfiguration})
      : super(key: key);

  final VideoPlayerController controller;
  final int videoConfiguration;

  Widget build(BuildContext context) {

    /// Return the buildVideo widget, which contains the user controls(play/pause) and scrubbing.
    if (videoConfiguration == 0 && controller.value.isInitialized) {
      return Container(
          alignment: Alignment.topCenter,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              buildVideoPlayer(),
              VideoOverlayWidget(controller: controller),
            ],
          ));
    }
    /// Return the buildVideoHome widget, which does NOT contain user controls or scrubbing.
    else if ((videoConfiguration == 1 || videoConfiguration == 2 || videoConfiguration == 3 || videoConfiguration == 4) && controller.value.isInitialized) {
      return Container(
          alignment: Alignment.topCenter,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              buildVideoPlayer(),
            ],
          ));
    } else {
      return LoadingScreen(displayVisual: 'loading icon',);
    }
  }

  /// Return video player
  // uses Aspect Ratio to make sure the video is "Stretched" to fit its container
  // while maintaining the correct resolution
  Widget buildVideoPlayer() => buildFullScreen(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );

  /// Video fits entire screen.
  /// Takes the actual video size and expands it to fit full screen.
  Widget buildFullScreen({
    @required Widget? child,
  }) {
    final size = controller.value.size;
    final width = size.width;
    final height = size.height;

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}


/// ***************************************************
/// Play, pause buttons, and video scrubber widgets
/// ***************************************************

class VideoOverlayWidget extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoOverlayWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () =>
    controller.value.isPlaying ? controller.pause() : controller.play(),
    child: Stack(
      children: <Widget>[
        buildPlay(),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: buildIndicator(),
        ),
      ],
    ),
  );

  /// Video scrubbing widget
  Widget buildIndicator() => VideoProgressIndicator(
    controller,
    allowScrubbing: true,
  );

  /// Display play button when video isn't playing
  Widget buildPlay() => controller.value.isPlaying
      ? Container()
      : Container(
    alignment: Alignment.center,
    color: Colors.black26,
    child: Icon(Icons.play_arrow, color: Colors.white, size: 80),
  );
}


