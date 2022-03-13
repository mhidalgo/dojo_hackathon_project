import 'dart:async';
import 'package:dojo_app/models/game_model2.dart';
import 'package:dojo_app/models/game_model2_extras.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/services/match_service.dart';
import 'package:dojo_app/services/timer_service.dart';
import '../../services/play_audio_service.dart';
import '../../widgets/host_card.dart';
import 'package:dojo_app/models/game_model.dart';
import 'package:dojo_app/widgets/timer_card.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/services/database_service.dart';
import 'build_game_screen_widgets.dart';
import 'package:dojo_app/constants.dart' as constants;
import 'package:dojo_app/globals.dart' as globals;

/// ***********************************************************************
/// ***********************************************************************
/// The game bloc has a few major jobs
/// 1. Load gamebloc with gameInfo object for a new game or existing game
/// 2. navigate through the game screen
/// 3. Display widgets on the screen based on game stage
/// 4. Save data for players
///
/// IMPORTANT DATA:
/// GameInfo object: this is extensively used throughout the class

/// How to follow the logic in this class
// follow SetupGame code
  // Initialize game config variables (timers, music, content, etc)
  // create GameInfo Object (info from levels and matches doc)
  // setup timers
  // start listening to game_screen
  // To Do: game_screen switches from loading to game experience
  // gameStage.start to populate game_screen with initial widgets and play music

// then follow listenUiEventStream code
  // both methods will call the other methods in this class and other files like...
  // files in services folder: database_service, helper_functions, build_game_screen_widgets

// Player1 is the player using the app, and player2 is the opponent
// Use this point of view to understand how to handle the data and for who

/// ***********************************************************************
/// ***********************************************************************

// Used to determine which widgets or actions to take place
// based on the user's location in the game
enum GameStage {
  Start,
  Next,
  SetupEnvironment,
  Tutorial,
  PushupTestWithML,
  GetReady,
  Countdown,
  Play,
  TimerExpires,
  ProvideScore,
  ShowPersonalResult,
  ShowAllResults,
  NextSteps,
  Exit,
}

enum RecordingEnum { StartRecording, StopRecording, StartStreamWithoutRecording, StopStreamWithoutRecording, DoNothing }
enum cameraSize { Full, Small } // Size of the recording camera game_screen UI screen
enum videoPlayerConfig {none, opponent, self} // which video should display on the game_screen UI

class GameBloc {
  /// ***********************************************************************
  /// GameBloc Constructor
  /// ***********************************************************************
  GameBloc({
    required this.gameMap,
    required this.gameMode,
    required this.groupID,
    required this.userID,
    required this.id,
    required this.opponentVideoAvailable,
    required this.playerOneRecords}) {

    /// Instantiate game model and populate with a new game or existing game data
    // creates the gameInfo object and stores it in global file so it's accessible everywhere in this class
    setupGame();
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  // unique game ID for each game a player starts
  // late String gameID;

  /// Get passed in parameters required for GameBloc
  // helps determine the type of game so the bloc can decide how to configure this game
  // the globals are initially populated on the game_screen.dart
  late String userID = userID; // this user
  late String playerOneUserID = userID;
  late String gameMode = gameMode; // levels, async 2p match
  late String groupID = groupID; // levels, matches
  late String id = id; // used to be levelID, matchID
  late bool opponentVideoAvailable = opponentVideoAvailable; // show opponent video or not
  late Map gameMap;// contains every field in level/match
  late Map playerOneRecords; // contains personal record, win/loss, scores over time for this player

  /// Note regarding opponentVideoAvailable boolean
  // determines how the UI should work based on if there is an opponent video to display
  // in levels, there is always an opponent video available
  // in matches, there is ONLY an opponent video if it is the 2nd player to play

  // Instantiate general databaseServices object that contains methods to CRUD on firebase
  DatabaseServices databaseServices = DatabaseServices();

  // Instantiate match service which contains methods used by multiple screens
  MatchService matchService = MatchService();

  // GameInfo contains game related info (ex. player names, scores, title, etc)
  // GameInfo is a replica of the match/level document
  // GameInfoExtra is additional information used by this bloc
  // cGameInfo is for higher level scope access
  late GameModel2 lgGameInfo;
  late GameModel2Extras lgGameInfoExtras;

  // Opponent ID which can be shared with game_screen, manipulate user, and to display their content
  late String opponentUserID;

  // For level games only: determines how data should be saved and UX logic
  bool currentPlayerIsWinner = false;

  // Contains widgets that will be added to the game UI sink
  List<Widget> myWidgets = []; // list that populates game screen dynamically

  // Store cached videos
  var cachedMovementTutorialVideo;

  // Game screen stopRecording() method will update these values to inform game bloc to move forward from the saving stage
  String videoURLtoSave = ''; // currently unused
  bool uploadURLAvailable = false; // Game Screen StopRecording() method updates this when it's completed a process that needs to happen before game bloc saving can move forward

  // Declare music parameters here when you want them to be disposed when dispose() is called
  late PlayAudio introMusic;
  late PlayAudio workoutMusic;

  // Setup workout timer so they can be closed when dispose() is called
  late TimerService countdownTimer;
  late TimerService workoutTimer;
  late TimerService saveGameTimer;
  late TimerService updateGameTimer;

  // Declare levels specific data
  // late double level; // specific level of a match

  // Setup other variables
  late String playerTwoUserID;

  /// ***********************************************************************
  /// Game Configurations
  /// ***********************************************************************

  // Timers
  int cCountdownTimer = constants.cCountdownTimer; // pre workout countdown to start
  int cWorkoutTimer = constants.cWorkoutTimer; // workout duration. this should be refactored to dynamically obtain the time from the gameRules document
  int cSaveGameTimer = 20; // max timeout for saving a video file, specifically, waiting for gameScreen stopRecording() method to generate an uploadURL
  int cUpdateGameTimer = 300; // unused

  // Images / Videos
  String movementVideoTutorial = 'images/pushup_with_cat4.gif';

  // Music
  String cIntroMusic =  'assets/audio/formula1_song_1st_half.mp3';
  String cWorkoutMusic = 'assets/audio/diggy_2017_4_song.mp3';
  String cYourResultsMusic = 'assets/audio/trumpet_songB.mp3';

  // SFX
  String cTimerExpiresSFX = 'assets/audio/basketball_buzzer.mp3';
  String cGoAudio = 'assets/audio/countdown_go_beep.mp3';
  String cYourResultsSFX1 = 'assets/audio/cheer1.mp3';
  String cAllResultsSFX1 = 'assets/audio/cheer1.mp3';
  String cDrumRollSFX = 'assets/audio/SFX_drumrollB.mp3';
  String cAllResultsSFX = 'assets/audio/SFX_all_results_reveal.mp3';
  String cYouWinVoice = 'assets/audio/SFX_you_winB.mp3';
  String cYouLoseVoice = 'assets/audio/SFX_you_loseB.mp3';
  String cYouWinSFX = 'assets/audio/cheer1.mp3';
  String cYouLoseSFX = 'assets/audio/SFX_lose_laugh.mp3';
  String cUnlockLevel = 'assets/audio/SFX_unlock_levelB.mp3';

  //Element Positioning
  // - Small camera position
  double posBottom = 40; // display here when there is no button displaying
  double posBottomHigher = 140.0; // when there is a button and you want to avoid the overlap
  double posLeft = 35.0;

  void setTimers () {
    countdownTimer = TimerService(countdown: cCountdownTimer);
    workoutTimer = TimerService(countdown: cWorkoutTimer);
    saveGameTimer = TimerService(countdown: cSaveGameTimer);
    updateGameTimer = TimerService(countdown: cUpdateGameTimer);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams
  /// ***********************************************************************
  /// ***********************************************************************

  /// Handles incoming events to signal UI changes (ex. the UI informs the stream something has happened)
  final _eventController = StreamController<GameStage>();
  Stream<GameStage> get eventStream => _eventController.stream;
  Sink<GameStage> get eventSink => _eventController.sink;

  /// Handles what should be displayed on UI (ex. since something happened, go do something like update the UI)
  final _uiController = StreamController<List<Widget>>();
  Stream<List<Widget>> get uiStream => _uiController.stream;
  Sink<List<Widget>> get gameScreenUISink => _uiController.sink;

  /// Handle the game button's config: visibility, text, action
  final _buttonController = StreamController<Map>();
  Stream<Map> get buttonControllerStream => _buttonController.stream;
  Sink<Map> get buttonControllerSink => _buttonController.sink;

  final _videoPlayerController = StreamController<Map>();
  Stream<Map> get videoPlayerControllerStream => _videoPlayerController.stream;
  Sink<Map> get videoPlayerControllerSink => _videoPlayerController.sink;

  ///Managing Camera for Video
  final _cameraUIController = StreamController<Map>();
  Stream<Map> get cameraUIControllerStream => _cameraUIController.stream;
  Sink<Map> get cameraUIControllerSink => _cameraUIController.sink;

  /// Save Score stream
  final _saveScoreController = StreamController<String>();
  Stream<String> get saveScoreControllerStream => _saveScoreController.stream;
  Sink<String> get saveScoreControllerSink => _saveScoreController.sink;

  /// ***********************************************************************
  /// ***********************************************************************
  /// This method is the starting point for all methods to start this bloc
  /// ***********************************************************************
  /// ***********************************************************************

  void setupGame() async {
    /// GameID is associated with a match ID or level ID as the unique identifier
    //gameID = createUUID();

    /// Obtain level / opponent details (ex. name, id, score, gameMode)
    // gameMode: 'levels' is where a user plays against a pre-recorded Dojo boss
    // level and match documents are unique to each user, whereas game documents are shared between all players
    if (gameMode == 'levels' || gameMode == 'matches' || gameMode == 'king of the hill') {

      /// Create game object that will be referenced
      // the game object is used throughout the rest of this class
      // gameInfo is used to create / save to the game document
      // whereas a game document is shared among all players of that game
      lgGameInfo = matchService.createGameObject(gameMap);
      lgGameInfoExtras = matchService.createGameExtrasObject(gameMap, playerOneUserID);

      // update with playerOneRecords
      lgGameInfoExtras.playerOneRecords = playerOneRecords;

      /// Instantiate timers now
      // so that if a user exits early, we will call dispose on an object that exists
      setTimers();

      /// Start listening to Game_Screen UI for events
      // this listens for signals to manage what is shown on the game_screen.dart
      // this is where all the logic starts
      listenUiEventStream();

      /// Triggers initial widgets to display on game screen
      eventSink.add(GameStage.Start);

    }
  } // end SetupGame()

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  /// close objects to prevent performance issues
  void dispose() {
    printBig('Gamebloc dispose called', 'TRUE');
    _eventController.close();
    _buttonController.close();
    _uiController.close();
    _saveScoreController.close();
    _videoPlayerController.close();
    _cameraUIController.close();
    introMusic.dispose();
    workoutMusic.dispose();
    countdownTimer.dispose();
    workoutTimer.dispose();
    saveGameTimer.dispose();
    updateGameTimer.dispose();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Save Score methods
  /// ***********************************************************************
  /// ***********************************************************************

  /// Input field (saving score) onChange action
  // Add input value to Sink, where it will be stored in the game model object
  void saveScoreInputFieldAction(value) {
    saveScoreControllerSink.add(value);
  }

  /// Listen to changes on the score input field
  /// And store in the gameInfo Object
  // This is called anytime a value is added to the saveScoreControllerSink
  listenToScoreInputField() {
    saveScoreControllerStream.listen((value) {
      // store value in the game model object so we can reference it later
      dynamic repScoreInputFieldValue = value;

      // save the total score to playerScore GameInfo object
      lgGameInfo = setPlayerScoreToGameObject(lgGameInfo, lgGameInfoExtras, repScoreInputFieldValue.toString());
    });
  }

  /// Game Screen can use this method as a setter to inform game bloc when a video is available
  // currently, this is not used
  // but could be re-purposed to have GameScreen stop recording method
  // to inform Game Bloc when to move forward
  void updateVideoURLtoSave(String videoURL) {
    videoURLtoSave = videoURL;
  }

  /// Game Screen stop recording method informs Game Bloc when an uploadURL is available
  // so that game bloc knows it can move forward from "wait while we save" message
  void updateUploadURLAvailable(bool isAvailable) {
    uploadURLAvailable = isAvailable;
  }

  /// this function is passed into the score input field button onPress
  // on tap of "save score" button, the following events take place
  saveScoreButtonAction() async {
    /// User just tapped save button, so display a "Saving" or "Loading" type message
    // add to widgetList: host card with "saving video..." message
    myWidgets = [];
    myWidgets.add(buildSavingDescription());
    gameScreenUISink.add(myWidgets);

    /// When saving is complete, then auto navigate to your results page
    if (gameMode == 'levels' || gameMode == 'matches' || gameMode == 'king of the hill') {
      /// Delay saving the game to provide time for
      // 1. stop recording to start and kick off a few tasks...
      // a 3 second timer to prevent code from moving forward.
      // this can be changed to actually trigger when Game Screen's stop recording method
      // is ready for game bloc to move forward
      saveGameTimer.startTimer();

      saveGameTimer.timeStream.listen((int _count) async {
        // Wait until we have the URL, then save data to database
        // we wait and listen because it takes time for the file to save to firebase storage, then the URL will be ready
        if (uploadURLAvailable == true || _count == 1) {
          // exit saveGameTimer loop because we finally have a video URL
          saveGameTimer.cancelTimer();

          await saveGameData();

          /// Move to next game stage
          eventSink.add(GameStage.ShowPersonalResult);
          // eventSink.add(nextStage); // doesn't work when passing in this enum, this is the preferred method so leaving this here until we solve it
        } // end if statement
      });
    }
  }

  /// This houses all logic of when and where to save game data to firebase
  Future<void> saveGameData() async {
    /// ***********************************************************************
    /// Save Data for King of the Hill
    /// ***********************************************************************
    if (gameMode == 'king of the hill') {
      // this is the 1st player where their opponent has not played yet

      /// Set overall game status
      // close = both players have played, open = not all players have played
      lgGameInfo.gameStatus = constants.cGameStatusClosed;

      /// Set the date this match was closed
      // this is used by the discord bot to determine what was updated last
      lgGameInfo.dates[constants.cMatchClosed] = DateTime.now();
      lgGameInfo.dates[constants.cPlayersScoreUpdated] = DateTime.now();

      /// Update playerGameOutcomes for this player only
      // 'pending' means the user has played and is waiting for their opponent to play
      // opponent's current outcome remains the same (open)
      lgGameInfo.playerGameOutcomes[playerOneUserID] = constants.cPlayerGameOutcomePending;

      /// Set the date this match was closed
      // this is used by the discord bot to determine what was updated last
      lgGameInfo.dates[constants.cPlayersScoreUpdated] = DateTime.now();

      // update match doc in matchesFlat collection
      databaseServices.updateMatchesFlat(lgGameInfo, lgGameInfoExtras);

      // add judging request
      databaseServices.create3rdPartyJudgeRequest2(gameMap);
      printBig('judge request', 'true');

      // add leaderboard item
      databaseServices.addToLeaderboard(gameMap);
    }
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Update gameInfo object with new data
  /// ***********************************************************************
  /// ***********************************************************************
  // This has been broken out like this so it is easy to identify when
  // we are adding more to the game info object
  // I don't think this is absolutely necessary, but it helps make
  // this game bloc file a tad easier to read

  GameModel2 setPlayerScoreToGameObject(GameModel2 gameInfo, GameModel2Extras gameInfoExtras, String scoreInputFieldValue) {
    gameInfo.playerScores[gameInfoExtras.playerOneUserID] = int.parse(scoreInputFieldValue);
    return gameInfo;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Timer Widgets
  /// ***********************************************************************
  /// ***********************************************************************

  /// This is the 10,9,8... 3,2,1 Go countdown
  /// which plays before the workout starts
  void buildCountdown(nextStage) {
    countdownTimer.startTimer();

    countdownTimer.timeStream.listen((int _count) {
      if (_count == 0) {
        eventSink.add(nextStage);
      } else {
        myWidgets = [];
        myWidgets.add(
          HostCard(
            headLine: 'Get Ready Countdown',
            bodyText: '$_count',
            loud: true,
            transparency: true,
          ),
        );

        buildCountdownSFX(_count);
        gameScreenUISink.add(myWidgets);
      }
    });
  }

  /// This is the workout timer
  void buildGameTimer(int gameDuration, nextGameStage) {
    workoutTimer.startTimer();

    workoutTimer.timeStream.listen((int _count) {
      if (_count == 0) {
        myWidgets = [];
        myWidgets.add(TimerCard(timer: _count));
        eventSink.add(nextGameStage);
      } else {
        myWidgets = [];
        myWidgets.add(TimerCard(timer: _count));
        gameScreenUISink.add(myWidgets);

        /// First 3 seconds of game timer, display host card
        if (_count == gameDuration || _count == gameDuration - 1 || _count == gameDuration - 2) {
          myWidgets.add(
            HostCard(
              headLineVisibility: false,
              bodyText: 'Go!',
              loud: true,
              transparency: true,
            ),
          );
        }
      }
    });
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Manage game stages, what to show, and what to do on the GameScreen UI
  /// ***********************************************************************
  /// ***********************************************************************

  /// This is called when a new event is added to eventSink of _uiController
  listenUiEventStream() {
    // Preload a few of the music tracks
    introMusic = PlayAudio(audioToPlay: cIntroMusic);
    workoutMusic = PlayAudio(audioToPlay: cWorkoutMusic);
    PlayAudio timerExpiresSFX = PlayAudio(audioToPlay: cTimerExpiresSFX);

    eventStream.listen((GameStage event) {
      /// ***************************************************************
      ///              STAGE: START
      /// ***************************************************************
      /// When game screen loads, then display these widgets initially
      if (event == GameStage.Start) {

        /// Play intro music
        introMusic.play();

        /// Build host chat cards and display on UI
        List introList = buildIntro(lgGameInfo, lgGameInfoExtras);

        // set initial time to wait before displaying first widget
        int timerDuration = 500;

        // loop to display each widget
        introList.forEach((element) {
          Timer(Duration(milliseconds: timerDuration), () {
            /// Remind the user what they're about to get into
            myWidgets.add(element);

            /// add widgets to sink so it appears on the game screen view
            gameScreenUISink.add(myWidgets);
          });
          // increment timer
          timerDuration = timerDuration + 1000;
        });

        Timer(Duration(milliseconds: timerDuration), () {
          /// Manage game screen button settings
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Let\'s go!',
            'onPressButtonAction': GameStage.Countdown,
            'cameraRecordAction': RecordingEnum.StartRecording,
          };
          buttonControllerSink.add(buttonConfig);
        });
      }

      /// ***************************************************************
      ///                STAGE: SETUP ENVIRONMENT
      /// ***************************************************************

      if (event == GameStage.SetupEnvironment) {
        /// clear the list so the view removes previous widgets
        myWidgets = [];
        gameScreenUISink.add(myWidgets);

        /// Setup their environment
        Timer(Duration(milliseconds: 500), () {
          /// Explain how to position themselves on camera
          myWidgets.add(buildSetupEnvironment());

          /// Add widgets to game screen view
          gameScreenUISink.add(myWidgets);
        });

        Timer(Duration(milliseconds: 1500), () {
          /// Manage game screen button settings
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Ok, I can see my whole body.',
            'onPressButtonAction': GameStage.Tutorial,
            'cameraRecordAction': RecordingEnum.DoNothing,
          };
          buttonControllerSink.add(buttonConfig);
        });
      }

      /// ***************************************************************
      ///                STAGE: TUTORIAL
      /// ***************************************************************
      /// Stage = Tutorial
      if (event == GameStage.Tutorial) {
        /// clear the list so the view removes previous widgets
        myWidgets = [];
        gameScreenUISink.add(myWidgets);

        Timer(Duration(milliseconds: 750), () {
          /// Display a tutorial description and video
          myWidgets.add(buildTutorialDescription());

          /// Add widgets to game screen view
          gameScreenUISink.add(myWidgets);

          myWidgets.add(buildTutorialVideo(file: movementVideoTutorial));
          gameScreenUISink.add(myWidgets);
        });

        Timer(Duration(milliseconds: 750), () {
          /// Manage button visibility, text, and onPress actions
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'I understand',
            'onPressButtonAction': GameStage.PushupTestWithML,
            'cameraRecordAction': RecordingEnum.StartStreamWithoutRecording,
          };
          buttonControllerSink.add(buttonConfig);
        });
      }

      /// ***************************************************************
      ///                STAGE: Pushup Test with ML
      /// ***************************************************************
      /// Stage = PushupTestWithML
      if (event == GameStage.PushupTestWithML) {
        /// clear the list so the view removes previous widgets
        myWidgets = [];
        gameScreenUISink.add(myWidgets);
        cameraUIControllerSink.add({
          'cameraMode': 'repCountMode'
        });

        Timer(Duration(milliseconds: 750), () {
          /// Display a tutorial description and video
          myWidgets.add(buildPushupTestDescription());

          /// Add widgets to game screen view
          gameScreenUISink.add(myWidgets);
        });

        Timer(Duration(seconds: 10), () {
          /// Manage button visibility, text, and onPress actions
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Next',
            'onPressButtonAction': GameStage.GetReady,
            'cameraRecordAction': RecordingEnum.StopStreamWithoutRecording,
          };
          buttonControllerSink.add(buttonConfig);

        });

      }

      /// ***************************************************************
      ///                STAGE: GET READY
      /// ***************************************************************
      /// Stage = Get Ready
      if (event == GameStage.GetReady) {

        cameraUIControllerSink.add({
          'cameraMode': 'full'
        });

        /// Clear the list so the view removes previous widgets
        myWidgets = [];
        gameScreenUISink.add(myWidgets);

        /// Move camera out of the way from the button
        // when opponent video is available, make the camera small so player can see their opponent
        if (opponentVideoAvailable == true) {
          // Display video recorder in thumbnail size
          cameraUIControllerSink.add({
            'cameraMode': 'small',
            'recordingIconVisibility': false,
            'posBottom': posBottom,
            'posLeft': posLeft,
          });

          /// Display video player with opponent's video, in full screen
          videoPlayerControllerSink.add({'videoPlayerMode': 'opponent'});
        }

        /// Build host chat cards and display on UI
        List getReadyList = buildGetReady(lgGameInfo, lgGameInfoExtras);
        int timerDuration = 500;
        getReadyList.forEach((element) {
          Timer(Duration(milliseconds: timerDuration), () {
            /// Remind the user what they're about to get into
            myWidgets.add(element);

            /// add widgets to sink so it appears on the game screen view
            gameScreenUISink.add(myWidgets);
          });
          // increment timer
          timerDuration = timerDuration + 1000;
        });

        Timer(Duration(milliseconds: timerDuration), () {

          /// When there is an opponent, the camera is smaller so the player can see opponent video
          // when the button is hidden, the camera is too high
          // move the camera lower so it uses the screen real estate more efficiently
          if (opponentVideoAvailable == true) {
            // Display video recorder in thumbnail size but above the primary button so it isn't obstructed
            cameraUIControllerSink.add({
              'cameraMode': 'small',
              'recordingIconVisibility': false,
              'posBottom': posBottomHigher,
              'posLeft': posLeft,
            });
          }

          /// Manage game screen button
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'I\'m ready. Start the countdown.',
            'onPressButtonAction': GameStage.Countdown,
            'cameraRecordAction': RecordingEnum.StartRecording,
          };
          buttonControllerSink.add(buttonConfig);
        });
      }

      /// ***************************************************************
      ///                STAGE: COUNTDOWN
      /// ***************************************************************
      /// Stage = 10,9...3,2,1 countdown to start
      if (event == GameStage.Countdown) {

        cameraUIControllerSink.add({
          'cameraMode': 'full'
        });

        /// Move camera UI down on UI
        // note: there is no button displayed during this time so move the button down to use available real estate
        if (opponentVideoAvailable == true) {
          // Display video recorder in thumbnail size
          cameraUIControllerSink.add({
            'cameraMode': 'small',
            'recordingIconVisibility': true,
            'posBottom': posBottom,
            'posLeft': posLeft,
          });
        }

        /// stop and close intro song player object
        introMusic.stop();

        /// clear the list so the view removes previous widgets
        myWidgets = [];
        gameScreenUISink.add(myWidgets);

        /// Display the 10,9...3,2,1 countdown
        // When timer service reaches 0, it auto starts the GameStage passed into this function
        buildCountdown(GameStage.Play);
      }

      /// ***************************************************************
      ///                STAGE: Game Timer Starts
      /// ***************************************************************
      /// Stage = Game in progress so show the game timer

      if (event == GameStage.Play) {
        /// Clear the list so the view removes previous widgets
        myWidgets = [];

        /// Display game timer
        // When timer reaches 0, it auto starts the next game stage
        // passes gameDuration so it knows when to show GO GO GO message
        // passes Game stage to load when timer reaches 0
        buildGameTimer(lgGameInfoExtras.gameDuration, GameStage.TimerExpires);

        /// Play GO audio
        PlayAudio goAudio = PlayAudio(audioToPlay: cGoAudio);
        goAudio.play();
        //workoutMusic.play();
      }

      /// ***************************************************************
      ///                STAGE: PLAY TIMER EXPIRES
      /// ***************************************************************
      /// Stage = Game timer expires
      if (event == GameStage.TimerExpires) {
        Timer(Duration(milliseconds: 1), () {
          /// Play game timer ends SFX
          timerExpiresSFX.play();

          /// Move self recording camera UI up, so the button doesn't overlap it
          if (opponentVideoAvailable == true) {
            cameraUIControllerSink.add({
              'cameraMode': 'small',
              'recordingIconVisibility': true,
              'posBottom': posBottomHigher,
              'posLeft': posLeft,
            });
          }

          /// The timer has expired so inform the user to stop
          myWidgets.add(buildGameTimeExpires());

          /// Stop and dispose workout music if it's still playing
          //workoutMusic.stop();

          /// add widgets to game screen view
          gameScreenUISink.add(myWidgets);
        });

        Timer(Duration(milliseconds: 1), () {
          /// manage button visibility, text, and onPress actions
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Add my rep count',
            'onPressButtonAction': GameStage.ProvideScore,
            'cameraRecordAction': RecordingEnum.StopRecording,
          };
          buttonControllerSink.add(buttonConfig);
        });
      }

      /// ***************************************************************
      ///                STAGE: SAVE SCORE
      /// ***************************************************************
      /// Stage = Input # of reps completed
      if (event == GameStage.ProvideScore) {

        /*/// Hide small camera UI
        if (opponentVideoAvailable == true) {
          cameraUIControllerSink.add({'cameraMode': 'hidden',});
        }*/

        /// Wait 1 second before switching to the selfie video
        /// Need to wait so that stop recording can execute creating the local file URL
        /// so that it can be played back
        Timer(Duration(milliseconds: 1000), () {
          /// Hide the camera recording the user so they can see their recorded video
          cameraUIControllerSink.add({'cameraMode': 'hidden',});

          /// Inform video player to display the player's just recorded video
          videoPlayerControllerSink.add({'videoPlayerMode': 'self'});
        });

        /// start listening to the score input field values
        listenToScoreInputField();

        /// clear the list so the view removes previous widgets
        myWidgets = [];
        gameScreenUISink.add(myWidgets);

        /// Collect players rep count
        Timer(Duration(milliseconds: 500), () {
          myWidgets.add(buildSaveScoreDescription());

          /// Display Save score form and button with actions
          myWidgets.add(buildSaveGameScoreForm(saveScoreInputFieldAction,saveScoreButtonAction));

          /// add widgets to game screen view
          gameScreenUISink.add(myWidgets);
        });
      }

      /// ***************************************************************
      ///                STAGE: SHOW INDIVIDUAL RESULT
      /// ***************************************************************
      /// Stage = Show their results
      if (event == GameStage.ShowPersonalResult) {

        /// Clear the list so the view removes previous widgets
        myWidgets = [];
        gameScreenUISink.add(myWidgets);

        Timer(Duration(milliseconds: 500), () {
          /// Display an individual player's results and stats
          myWidgets.add(buildYourResultsDescription(gameMode));
          myWidgets.add(buildYourResultsCard(
            gameMode: gameMode,
            gameInfo: lgGameInfo,
            gameInfoExtras: lgGameInfoExtras,
          ),);

          /// Play end of game music and SFX
          PlayAudio yourResultsMusic = PlayAudio(audioToPlay: cYourResultsMusic);
          yourResultsMusic.play();
          PlayAudio yourResultsSFX1 = PlayAudio(audioToPlay: cYourResultsSFX1);
          yourResultsSFX1.play();

          /// Add widgets to game screen view
          gameScreenUISink.add(myWidgets);
        });

        Timer(Duration(milliseconds: 500), () {
          /// Manage button text and action
          Map buttonConfig;
          if (opponentVideoAvailable) {
            buttonConfig = {
              'buttonVisibility': true,
              'buttonText': 'Tell me who won',
              'onPressButtonAction': GameStage.ShowAllResults,
              'cameraRecordAction': RecordingEnum.DoNothing,
            };
          } else {
            buttonConfig = {
              'buttonVisibility': true,
              'buttonText': 'Tell me what is next',
              'onPressButtonAction': GameStage.NextSteps,
              'cameraRecordAction': RecordingEnum.DoNothing,
            };
          }
          buttonControllerSink.add(buttonConfig);
        });
      }

      /// ***************************************************************
      ///                STAGE: Show both player results
      /// ***************************************************************
      /// Stage = Show both player results, if there is any
      // currently, this is always true with levels
      bool allResultsAvailable = true;
      if (event == GameStage.ShowAllResults) {
        if (allResultsAvailable == true) {
          /// Clear list so view removes previous widgets
          myWidgets = [];
          gameScreenUISink.add(myWidgets);

          /// Play both player results SFX
          PlayAudio allResultsSFX1 = PlayAudio(audioToPlay: cAllResultsSFX1);
          PlayAudio drumRollSFX = PlayAudio(audioToPlay: cDrumRollSFX);
          PlayAudio allResultsSFX = PlayAudio(audioToPlay: cAllResultsSFX);
          allResultsSFX1.play();
          drumRollSFX.play();

          Timer(Duration(milliseconds: 500), () {
            /// Explain what they are about to see
            myWidgets.add(buildAllResultsDescription());

            /// Add widgets to game screen view
            gameScreenUISink.add(myWidgets);
          });

          Timer(Duration(milliseconds: 1700), () {
            /// Play SFX
            allResultsSFX.play();
          });

          Timer(Duration(milliseconds: 2000), () {
            /// Display both player results
            myWidgets.add(buildAllResultsCardWithGameObject(lgGameInfo, lgGameInfoExtras));

            /// add widgets to game screen view
            gameScreenUISink.add(myWidgets);
          });

          /// display win, lose, or tie message
          Timer(Duration(milliseconds: 3500), () {

            // TODO refactor to play SFX during gameMode: LEVELS
            // currently, does not play loser voice SFX, when the player does not win in levels
            /// Play SFX based on win or loss
            playWinnerOrLoserSFX2(
              sfxTrackWin: cYouWinVoice,
              sfxTrackLose: cYouLoseVoice,
              playerGameOutcomes: lgGameInfo.playerGameOutcomes,
              userID: lgGameInfoExtras.playerOneUserID,
            );

            Timer(Duration(milliseconds: 800), () {
              playWinnerOrLoserSFX2(
                sfxTrackWin: cYouWinSFX,
                sfxTrackLose: cYouLoseSFX,
                playerGameOutcomes: lgGameInfo.playerGameOutcomes,
                userID: lgGameInfoExtras.playerOneUserID,);
              });

            /// Inform the player won or lost or tied
            if (lgGameInfo.gameMode == 'matches') {
              myWidgets.add(buildYouWinOrLoseOrTieDescription(lgGameInfo.playerGameOutcomes, lgGameInfoExtras.playerOneUserID));
            } else if (lgGameInfo.gameMode == 'levels') {
              myWidgets.add(buildYouWinOrLoseDescription(currentPlayerIsWinner));
            }

            /// Add widgets to game screen view
            gameScreenUISink.add(myWidgets);
          });

          Timer(Duration(milliseconds: 3500), () {
            /// Manage button visibility and text
            Map buttonConfig = {
              'buttonVisibility': true,
              'buttonText': 'Tell me what is next',
              'onPressButtonAction': GameStage.NextSteps,
              'cameraRecordAction': RecordingEnum.DoNothing,
            };
            buttonControllerSink.add(buttonConfig);
          });
        }
      } // end if statement

      /// ***************************************************************
      ///                STAGE: Next Steps
      /// ***************************************************************
      /// Stage = Let the player what they should do next
      if (event == GameStage.NextSteps) {

        /// Clear widgets from game screen
        myWidgets = [];
        gameScreenUISink.add(myWidgets);

        if (gameMode == 'levels') {
          /// Play SFX based on win or loss
          Timer(Duration(milliseconds: 500), () {
            playWinnerOrLoserSFX2(
                sfxTrackWin: cUnlockLevel,
                sfxTrackLose: '0',
                playerGameOutcomes: lgGameInfo.playerGameOutcomes,
                userID: lgGameInfoExtras.playerOneUserID);
          });
        }

        /// Build host chat cards and display on UI
        List nextStepsList = buildNextSteps(lgGameInfo, lgGameInfoExtras, currentPlayerIsWinner);
        int timerDuration = 500;
        nextStepsList.forEach((element) {
          Timer(Duration(milliseconds: timerDuration), () {
            /// Remind the user what they're about to get into
            myWidgets.add(element);

            /// add widgets to sink so it appears on the game screen view
            gameScreenUISink.add(myWidgets);
          });
          // increment timer
          timerDuration = timerDuration + 1000;
        });

        Timer(Duration(milliseconds: timerDuration), () {
          /// Manage button visibility and text
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Exit',
            'onPressButtonAction': GameStage.Exit,
            'cameraRecordAction': RecordingEnum.DoNothing,
            'redirect': '$gameMode',
          };
          buttonControllerSink.add(buttonConfig);
        });
      } // end gameStage next steps
    });
  }
}
