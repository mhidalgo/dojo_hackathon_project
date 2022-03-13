import 'dart:convert';
import 'package:dojo_app/screens/levels/levels_wrapper.dart';
import 'package:dojo_app/screens/matches_A2P/matches_wrapper.dart';
import 'package:dojo_app/screens/video_player/video_full_screen.dart';
import 'package:dojo_app/screens/wrapper.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/widgets/loading_icon.dart';
import 'package:dojo_app/widgets/loading_screen_static.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:page_transition/page_transition.dart';
import '../../style/colors.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/close_icon_button.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/widgets/recording_icon.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'game_bloc.dart';
import 'package:wakelock/wakelock.dart';
import 'package:async/async.dart';
import 'package:dojo_app/services/pose_estimation_services/motion_data_service.dart';
import 'package:dojo_app/services/pose_estimation_services/pose_painter_service.dart';
import 'package:http/http.dart' as http;





/// ***************************************************************
///
/// Game Page and Game Bloc work together
/// This job of this page includes...
/// - setting up game bloc which contains most of the logic
/// - setup and manage video player
/// - setup and manage camera recorder
/// - display UI
///
/// To Follow the logic of game_screen and gameBloc
/// - follow gameBloc
/// - then follow game_screen code
///
/// ***************************************************************

class GameScreen extends StatefulWidget {
  /// Game Screen Constructor
  GameScreen(
      {required this.gameScreenWrapperMap}) {
    //
  }

  // Contains required data for GameScreen
  // this comes from Game Screen Wrapper
  final Map gameScreenWrapperMap;

  // Front facing camera
  // TODO: move setting globals.camera from main.dart to here or to gameScreenWrapper
  final camera = globals.cameras[1];

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  /// _GameScreenState constructor
  _GameScreenState() {
    //
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get passed in variables
  late Map gameMap = widget.gameScreenWrapperMap['fullGameMap']; // contains every field in level/match doc
  late String gameMode = widget.gameScreenWrapperMap['gameMode'];
  late String groupID = widget.gameScreenWrapperMap['groupID'];
  late String id = widget.gameScreenWrapperMap['id'];
  late String opponentVideo = widget.gameScreenWrapperMap['opponentVideo'];
  late bool opponentVideoAvailable = widget.gameScreenWrapperMap['opponentVideoAvailable'];
  late String userID = widget.gameScreenWrapperMap['userID'];
  late Map playerOneRecords = widget.gameScreenWrapperMap['playerOneRecords'];

  /// Initialize database object for calls to the DB
  DatabaseServices databaseServices = DatabaseServices();

  /// Initialize Video Player
  late VideoPlayerController videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;
  String selfieVideoToPlay = '';
  late File localSelfieVideoToPlay;

  /// StopRecording() method uses the variables
  final videoName = createUUID(); // name of video
  String? uploadUrl;  // required for background uploading and required to save video file

  /// Initialize Camera
  late CameraController cameraController;
  //CameraController? cameraController;

  late Future<void> _initializeControllerFuture;
  late XFile videoFile; // Stores video file after its recorded

  ///ML Variables
  bool isBusy = false;
  PoseDetector poseDetector = GoogleMlKit.vision.poseDetector();
  MotionData motionData = new MotionData();
  CustomPaint? customPaint;

  ///Ipfs URL
  String ipfsVideoUrl = '';



  /// Instantiate bloc object (aka controller with all the logic)
  // this also starts a chain of methods in GameBloc to start informing this screen
  late GameBloc gameBloc = GameBloc(
    userID: userID,
    gameMode: gameMode,
    groupID: groupID,
    id: id,
    opponentVideoAvailable: opponentVideoAvailable,
    gameMap: gameMap,
    playerOneRecords: playerOneRecords,
  );

  /// Get uid of current User
  var currentUser = FirebaseAuth.instance.currentUser;

  /// Initialize List to contain which widgets to display
  // this is controlled and populated by the GameBloc
  List<Widget> myList = [];

  /// Contains data from video collection for specific doc
  late Stream<QuerySnapshot> _uploadVideoURLStream;
  Stream<QuerySnapshot> get uploadVideoURLStream => _uploadVideoURLStream;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Init and dispose methods
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  void initState() {
    super.initState();

    /// Prevent the screen from turning off
    Wakelock.enable();

    /// initialize video player (to view your opponent)
    // only becomes enabled if there is an opponent video available
    initializeVideoPlayer(opponentVideo);

    /// Initialize Camera (for recording)
    cameraController = CameraController(
      widget.camera, // Get a specific camera from the list of available cameras.
      ResolutionPreset.low, // Define the resolution to use.
    );

    /// Initialize specific instance of a camera
   _initializeControllerFuture = cameraController.initialize();

  } // end initState()

  /// When view is closed, dispose of gameBloc to prevent performance issues
  @override
  void dispose() {
    printBig('Game Screen Dispose Called', 'true');
    gameBloc.dispose();

    /// Wait 1 second before closing the cameraController or VideoPlayer
    // otherwise, the app returns an error because it tries to close this when it's in use
    Timer(Duration(seconds: 1), () {
      cameraController.dispose();

      // 'levels' mode uses the video player to display the opponent video so close it
      if (opponentVideoAvailable == true) {
        videoPlayerController.dispose();
        printBig('Video DISPOSED', 'true');
      }
    });

    /// Screen will turn off when not in use for x seconds
    Wakelock.disable();

    super.dispose();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  void initializeVideoPlayer(String opponentVideo) {
    /// Display opponent video if available
    // opponent videos exist in...
    // levels: because there is always a computer player to play against
    // matches: when at least 1 player has already played

    if (opponentVideoAvailable) {
      videoPlayerController = VideoPlayerController.network(opponentVideo, videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
      _initializeVideoPlayerFuture = videoPlayerController.initialize();
    }
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Google Analytic Tracking Methods
  /// ***********************************************************************
  /// ***********************************************************************

  Future<void> _sendAnalyticsEventCompleteGame() async {
    await globals.Analytics.analytics.logEvent(
      name: 'complete_game',
      parameters: <String, dynamic>{
        'Game Completed': true,
      },
    );
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  void onPressButtonAction(gameStage, buttonControls) {
    /// hide button and set default button label
    Map buttonConfig = {
      'buttonVisibility': false,
      'buttonText': 'Disabled',
      'onPressButtonAction': 0,
    };
    gameBloc.buttonControllerSink.add(buttonConfig);

    if (gameStage == GameStage.Exit) {
      exitButtonAction(buttonControls['redirect']);
    } else {
      gameBloc.eventSink.add(gameStage);
    }
  }

  void exitButtonAction(String redirect) {
    // Exit button displays at the end of the game experience
    // dispose() is automatically called

    /// GA tracking
    _sendAnalyticsEventCompleteGame();

    // Redirect
    if (redirect == 'levels') {
      Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.bottomToTop, child: LevelsWrapper()), (Route<dynamic> route) => false);
    } else if (redirect == 'matches') {
      Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.bottomToTop, child: MatchesWrapper()), (Route<dynamic> route) => false);
    } else {
      Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.bottomToTop, child: Wrapper()), (Route<dynamic> route) => false);
    }
  }

  quitGameIconOnPress() {
    // Quit icon is available in game xp in upper left hand corner at all times
    // dispose() is automatically called
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.bottomToTop, child: Wrapper()), (Route<dynamic> route) => false);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Video Recording and Player Methods
  /// ***********************************************************************
  /// ***********************************************************************

  void manageCameraAction (cameraRecordAction) {
    if (cameraRecordAction == RecordingEnum.StartRecording) {
      startRecordingButtonAction();
    }

    if (cameraRecordAction == RecordingEnum.StopRecording) {
      stopRecordingButtonAction();
    }

    if (cameraRecordAction == RecordingEnum.StartStreamWithoutRecording) {
      startImageStream();
    }

    if (cameraRecordAction == RecordingEnum.StopStreamWithoutRecording) {
      stopImageStream();
    }
  }

  void startRecordingButtonAction() async {
    try {
      await _initializeControllerFuture;
      await cameraController.startVideoRecording();

      printBig('video recording starting', 'true');
    } catch (e) {
      printBig('video recording starting error...', 'true');
      print(e);
    }

    try {
      await _initializeVideoPlayerFuture;
      await videoPlayerController.play();
      videoPlayerController.play();
      printBig('video is playing', 'true');
    } catch (e) {
      printBig('video is broken', 'true');
    }
  }

  Future <void> stopRecordingButtonAction() async {
    printBig('video recording stopped', 'called');

    /// Record Video using camera package, convert to File format to save to Firebase
    final XFile file = await cameraController.stopVideoRecording();
    videoFile = file;

    //TODO: Omit dependency on this variable since we don't create a URL anymore.
    selfieVideoToPlay = 'firebaseStorageURL';

    /// Set local video location so it can be played back at the end of the game xp
    localSelfieVideoToPlay = File(videoFile.path);

    /// Save video file metadata to cloud firestore before upload.
    // this will start a cloud function to generate an upload URL
    await VideoDatabaseService.createNewVideoCollectionRecord(videoName, videoFile.path, gameBloc.id, userID, gameMode, groupID);

    uploadVideoIpfs(localSelfieVideoToPlay);

    /// Do not move forward until upload URL is available in videos collection document
    // upload URL is generated by a cloud function
    _uploadVideoURLStream = databaseServices.fetchVideosByID(videoName);
    var subscription;
    subscription = _uploadVideoURLStream.listen((event) async {

      if (event.docs.isNotEmpty) {
        Map videosMap = event.docs.first.data() as Map<dynamic, dynamic>;

        if (videosMap['uploadUrl'] != null) {
          /// Inform the gameBloc to move forward from displaying the message "saving..."
          gameBloc.updateUploadURLAvailable(true);

          /// Start uploading the video using the background flutter upload package.
          await databaseServices.uploadVideo(videoName, videoFile);

          /// Get videoURL from uploaded file and update this user's and opponent's match/level documents.
          await delayVideoURLandUpdateMatches();

          /// Stop listening to this stream so that it exits this loop
          subscription.cancel();
        }
      }
    });
  }


  ///Start and stop image streams for MLkit usage.
  Future <void> startImageStream() async {
    await cameraController.startImageStream(_processCameraImage);
  }

  Future <void> stopImageStream() async {
    await cameraController.stopImageStream();
    await poseDetector.close();
    motionData.dispose();
  }


  /// Delays execution of the VideoURLandUpdate Matches method.
  Future <void> delayVideoURLandUpdateMatches() async {

    /// Get videoURL from uploaded file and update this user's and opponent's match/level documents.
    // Note: This video URL contains the firebase security token so that it can be played back by a dojo user (security)
    // Note: Uses future delay to give the uploadVideo method time to finish
    // if it does not finish uploading in time, then the following will execute, but nothing will be saved
    // if that occurs then when this user, or their opponent, loads the matchesWrapper, this process will run again to update the leve
    Timer(Duration(seconds: 5),() async {
      await databaseServices.fetchVideoURLandUpdateMatches(gameMode, userID);
    });

  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// IPFS methods
  /// ***********************************************************************
  /// ***********************************************************************

  Future<void> uploadVideoIpfs(File imageFile) async {

    Map<String, String> headers = { "Authorization": "249a4ff4-846d-426a-9280-26c36a5952ca"}; //key for NFTPort
    //String videoUrl = '';

    // open a bytestream
    var stream = new http.ByteStream(imageFile.openRead());
    stream.cast();
    // get file length
    var length = await imageFile.length();

    // string to uri
    var uri = Uri.parse("https://api.nftport.xyz/v0/files");

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);
    request.headers.addAll(headers);

    // multipart that takes file
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: imageFile.path);

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();
    print(response.statusCode);

    await response.stream.bytesToString().then((value) {
      Map ipfsJSON = jsonDecode(value);
      ipfsVideoUrl = ipfsJSON['ipfs_url'];
      print(ipfsVideoUrl);
    });
    //return videoUrl;

    CollectionReference url = FirebaseFirestore.instance.collection('matchesAll2');

    await  url.doc(widget.gameScreenWrapperMap['id'])
          .update({'ipfsUrl': ipfsVideoUrl})
          .then((value) => print("URL Updated"))
          .catchError((error) => print("Failed to update user: $error"));



  }


  /// ***********************************************************************
  /// ***********************************************************************
  /// ML functions
  /// ***********************************************************************
  /// ***********************************************************************

  Future<void> _processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final poses = await poseDetector.processImage(inputImage);
    print('Found ${poses.length} poses');
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);

      motionData.pushUpRepCounter(poses);

      print('PROCESS IMAGE RUNNING');

      customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
    Size(image.width.toDouble(), image.height.toDouble());

    final camera = widget.camera;
    final imageRotation =
        InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = image.planes.map(
          (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
    InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    //widget.onImage(inputImage);
    _processImage(inputImage);

  }




  /// ***********************************************************************
  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primarySolidCardColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: (MediaQuery.of(context).size.height) - (MediaQuery.of(context).padding).top - (MediaQuery.of(context).padding).bottom,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        StreamBuilder<Map>(
                            stream: gameBloc.videoPlayerControllerStream,
                            initialData: {'videoPlayerMode': 'hidden'},
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                final videoPlayerMode = snapshot.data!['videoPlayerMode'] as String;

                                /// Displays video player with opponent's video
                                if (videoPlayerMode == 'opponent') {
                                  return FutureBuilder(
                                    future: _initializeVideoPlayerFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done) {

                                        // Limit the aspect ratio of the video.
                                        //Get height and width of actual video, and use that to scale video.
                                        final size = videoPlayerController.value.size;
                                        final width = size.width;
                                        final height = size.height;

                                        return FittedBox(
                                          fit: BoxFit.cover,
                                          child: SizedBox(width: width, height: height, child: AspectRatio(
                                            aspectRatio: videoPlayerController.value.aspectRatio,
                                            child: VideoPlayer(videoPlayerController),
                                          ),
                                          ),
                                        );
                                      } else {
                                        // If the VideoPlayerController is initializing, show a loading spinner.
                                        return LoadingScreenStatic(displayVisual: 'loading icon');
                                      }
                                    },
                                  );
                                  /// Displays video player with player's own video
                                } else if (videoPlayerMode == 'self') {
                                  Map videoMap = {'localVideoFile': localSelfieVideoToPlay};
                                  return VideoFullScreen(videoMap: videoMap, videoURL: selfieVideoToPlay, videoConfiguration: 1);
                                } else {
                                  // videoPlayerMode = hidden so do not show the widget
                                  return Container();
                                }
                              } else {
                                // snapshot.data has no data so display nothing
                                return Container();
                              }
                            }),
                        StreamBuilder<Map>(
                            stream: gameBloc.cameraUIControllerStream,
                            initialData: {'cameraMode': 'full'},
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                final cameraMode = snapshot.data!['cameraMode'] as String;
                                if (cameraMode == 'full' ) {
                                  return SizedBox.expand(
                                    child: FutureBuilder<void>(
                                      future: _initializeControllerFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done && cameraController.value.isInitialized) {
                                          var camera = cameraController.value;
                                          // fetch screen size
                                          final size = MediaQuery.of(context).size;

                                          // calculate scale depending on screen and camera ratios
                                          // this is actually size.aspectRatio / (1 / camera.aspectRatio)
                                          // because camera preview size is received as landscape
                                          // but we're calculating for portrait orientation
                                          var scale = size.aspectRatio * camera.aspectRatio;

                                          // to prevent scaling down, invert the value
                                          if (scale < 1) scale = 1 / scale;
                                          // If the Future is complete, display the preview.
                                          return  Transform.scale(
                                            scale: scale,
                                            child: Center(child: CameraPreview(cameraController)),
                                          );
                                        } else {
                                          // Otherwise, display a loading indicator.
                                          return LoadingScreenStatic(displayVisual: 'loading icon');
                                        }
                                      },
                                    ),
                                  );
                                } else if(cameraMode == 'repCountMode'){
                                  return Container(
                                    color: Colors.black,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: <Widget>[
                                        CameraPreview(cameraController),
                                        if (customPaint != null) customPaint!
                                      ],
                                    ),
                                  );
                                }
                                else if (cameraMode == 'small') {
                                  final recordingIconVisibility = snapshot.data!['recordingIconVisibility'] as bool;
                                  final posBottom = snapshot.data!['posBottom'] as double;
                                  final posLeft = snapshot.data!['posLeft'] as double;
                                  return Positioned(
                                    bottom: posBottom,
                                    left: posLeft,
                                    child: Container(
                                      height: (MediaQuery.of(context).size.height) * .14,
                                      width: (MediaQuery.of(context).size.width) * .21,
                                      padding: EdgeInsets.all(0.0),
                                     margin: EdgeInsets.all(0.0),
                                     decoration: BoxDecoration(
                                        borderRadius: borderRadius2(),
                                        boxShadow: [boxShadow1(),],
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          FutureBuilder<void>(
                                            future: _initializeControllerFuture,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.done && cameraController.value.isInitialized) {
                                                // If the Future is complete, display the preview.
                                                var camera = cameraController.value;
                                                // fetch screen size
                                                final size = MediaQuery.of(context).size;

                                                // calculate scale depending on screen and camera ratios
                                                // this is actually size.aspectRatio / (1 / camera.aspectRatio)
                                                // because camera preview size is received as landscape
                                                // but we're calculating for portrait orientation
                                                var scale = size.aspectRatio * camera.aspectRatio;

                                                // to prevent scaling down, invert the value
                                                if (scale < 1) scale = 1 / scale;

                                                return Transform.scale(
                                                  scale: scale,
                                                  child: Center(
                                                    child: ClipRRect(
                                                          borderRadius: borderRadius2(),
                                                        child: CameraPreview(cameraController)),
                                                  ),
                                                );
                                              } else {
                                                // Otherwise, display a loading indicator.
                                                return const Center(child: LoadingAnimatedIcon());
                                              }
                                            },
                                          ),
                                          Visibility(visible: recordingIconVisibility, child: Positioned(child: RecordingIcon(), bottom: 0)),
                                        ],
                                      ),
                                    ),
                                  );
                                } else if (cameraMode == 'hidden') {
                                  return Container();
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            }),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Material(
                              color: primarySolidBackgroundColor.withOpacity(0.0),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: [QuitGameIcon(quitGameIconOnPress: quitGameIconOnPress)],
                                  ),
                                  StreamBuilder<List<Widget>>(
                                    stream: gameBloc.uiStream,
                                    initialData: [],
                                    builder: (context, snapshot) {
                                      if (snapshot.data != null) {
                                        final list = snapshot.data as List<Widget>;
                                        return Column(
                                          children: list,
                                        );
                                      } else {
                                        return Column(
                                          children: myList,
                                        );
                                      }
                                    },
                                  ),
                                  SizedBox(height: 24),
                                ],
                              ),
                            ),
                          /*  StreamBuilder<dynamic>(
                                stream: motionData.repCountStream,
                                builder: (context, snapshot) {
                                  if (snapshot.data != null) {
                                    var repCount = snapshot.data;
                                    String repCountString = repCount.toString();
                                    return Flexible(
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: primaryTransparentCardColor,
                                          borderRadius: borderRadius1(),
                                        ),
                                        child: Text('Reps: $repCountString',
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .headline3),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }
                            ),*/
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Stack(
                                    children: [
                                      StreamBuilder<Map>(
                                          stream: gameBloc.buttonControllerStream,
                                          initialData: {'buttonVisibility': false, 'buttonText': 'Disabled', 'onPressButtonAction': 0},
                                          builder: (context, snapshot) {
                                            if (snapshot.data != null) {
                                              final buttonControls = snapshot.data as Map;
                                              return Visibility(
                                                visible: buttonControls['buttonVisibility'],
                                                child: MediumEmphasisButton(
                                                  title: buttonControls['buttonText'],
                                                  onPressAction: () {
                                                    onPressButtonAction(buttonControls['onPressButtonAction'], buttonControls);
                                                    manageCameraAction(buttonControls['cameraRecordAction']);
                                                  },
                                                ),
                                              );
                                            } else {
                                              return Container();
                                            }
                                          }),
                                      StreamBuilder<dynamic>(
                                          stream: motionData.repCountStream,
                                          builder: (context, snapshot) {
                                            if (snapshot.data != null && snapshot.data < 3) {
                                              var repCount = snapshot.data;
                                              String repCountString = repCount.toString();
                                              var remainingReps = 3-repCount;
                                              return Container(
                                                width: (MediaQuery.of(context).size.width) * 0.80,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: primarySolidCardColor,
                                                  borderRadius: borderRadius1(),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text('$repCountString reps give me $remainingReps more!',
                                                      style: Theme
                                                          .of(context)
                                                          .textTheme
                                                          .headline4),
                                                ),
                                              );
                                            } else {
                                              return Container(width: (MediaQuery.of(context).size.width) * 0.80,
                                                height: 50,);
                                            }
                                          }
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 32),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    // top module
  }
}
