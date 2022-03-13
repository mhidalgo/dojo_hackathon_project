import 'package:dojo_app/nftport_poc/upload_ipfs_screen.dart';
import 'package:dojo_app/screens/game_modes/game_modes_wrapper.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/loading_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'dart:io';



class VideoNft extends StatefulWidget {
  const VideoNft({Key? key}) : super(key: key);

  @override
  _VideoNftState createState() => _VideoNftState();
}

class _VideoNftState extends State<VideoNft> {

  final camera = globals.cameras[1];
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  var _recordButtonPress = true;
  var _stopRecordButtonPress = false;
  late XFile videoFileLocation;
  late File videoFile;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
   }

  @override
  void dispose() {
    super.dispose();
      _controller.dispose();
  }

  backButtonAction() {
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: GameModesWrapper()),
            (Route<dynamic> route) => false);
  }

  recordButtonPressAction() async {
    try {
      await _initializeControllerFuture;
      await _controller.startVideoRecording();

      printBig('video recording starting', 'true');
    } catch (e) {
      printBig('video recording starting error...', 'true');
      print(e);
    }

  }

Future <File>  stopRecordingButtonAction() async {
    final XFile file = await _controller.stopVideoRecording();
    videoFileLocation = file;
    videoFile = File(videoFileLocation.path);
    return videoFile;
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              print('tap');
              backButtonAction();
            },
          ),
        ),
        body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context,snapshot) {
                if (snapshot.connectionState == ConnectionState.done && _controller.value.isInitialized) {
                return CameraPreview(_controller);
                } else {
                  return const Center(child: LoadingAnimatedIcon());
                }
               }
              ),
              Positioned(
                bottom: 20,
                right:20,
                left:20,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      HighEmphasisButton(title: 'Accept Picture',
                          onPressAction: () async {
                            if (_recordButtonPress) {

                              _recordButtonPress = false;
                              _stopRecordButtonPress = true;

                              await recordButtonPressAction();
                            }
                          }
                      ),
                      SizedBox(height: 20,),
                      MediumEmphasisButton(title: 'Stop Recording', onPressAction:() async {

                        if(_stopRecordButtonPress) {
                          _recordButtonPress = true;
                          _stopRecordButtonPress = false;
                          var file = await stopRecordingButtonAction();
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => UploadToIPFS(videoFile: file,videoFilePath: videoFileLocation.path,),));
                        }
                      }
                      ),
                    ]
                ),
              )
            ],
        ),
     ),
    );
  }
}
