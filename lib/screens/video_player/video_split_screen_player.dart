import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';

// TODO create new page that will display this split screen widget. Part of matches folder or a new screen ex "watch_two_videos_screen"
// TODO add video loading screen

class VideoSplitScreen extends StatefulWidget {
  VideoSplitScreen({Key? key, required this.thisPlayerVideo, required this.opponentPlayerVideo}) : super(key: key);
  final String thisPlayerVideo;
  final String opponentPlayerVideo;

  @override
  _VideoSplitScreenState createState() => _VideoSplitScreenState();
}

class _VideoSplitScreenState extends State<VideoSplitScreen> {
  final Map videoMap = {};
  late String thisPlayerVideo = widget.thisPlayerVideo;
  //'https://firebasestorage.googleapis.com/v0/b/dojo-app-prod.appspot.com/o/701732f0-27c2-11ec-a00d-1bd2e9f830f4.mp4?alt=media&token=bec4952a-d481-4e25-aa6a-79da72fa083f';
  late String opponentPlayerVideo = widget.opponentPlayerVideo;
  // 'https://firebasestorage.googleapis.com/v0/b/dojo-app-prod.appspot.com/o/701732f0-27c2-11ec-a00d-1bd2e9f830f4.mp4?alt=media&token=bec4952a-d481-4e25-aa6a-79da72fa083f';

  final FijkPlayer player1 = FijkPlayer();
  final FijkPlayer player2 = FijkPlayer();

  @override
  void initState() {
    super.initState();

    player1.setDataSource(
        thisPlayerVideo,
        autoPlay: true);
    player2.setDataSource(
        opponentPlayerVideo,
        autoPlay: true);
  }

  @override
  void dispose() {
    super.dispose();
    player1.release();
  }

  backButtonAction() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primarySolidBackgroundColor,
      //backgroundColor: Opacity(opacity: 0.25, child: BackgroundTopImage(imageURL: 'images/castle.jpg')),
      appBar: AppBar(
        title: PageTitle(title: 'TURN BASED 2 PLAYER'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            backButtonAction();
          },
        ),
        backgroundColor: primarySolidBackgroundColor,
      ),
      body: Material(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                //child: VideoFullScreen(videoMap: videoMap, videoURL: selfieVideoToPlay, videoConfiguration: 2),
                child: FijkView(player: player1,
                    fit: FijkFit.cover,
              )),
              Expanded(
                //child: VideoFullScreen(videoMap: videoMap, videoURL: selfieVideoToPlay, videoConfiguration: 2),
                child: FijkView(player: player2,
                    fit: FijkFit.cover,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
