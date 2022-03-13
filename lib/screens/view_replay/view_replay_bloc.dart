import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/models/game_model2.dart';
import 'package:dojo_app/models/game_model2_extras.dart';
import 'package:dojo_app/screens/game/build_game_screen_widgets.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/services/match_service.dart';
import 'package:dojo_app/services/play_audio_service.dart';
import 'package:dojo_app/services/timer_service.dart';
import 'package:dojo_app/services/web3_service.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:dojo_app/widgets/rate_form_questions.dart';
import 'package:dojo_app/widgets/view_replay_hud.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/constants.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/constants.dart' as constants;

// Used to determine which widgets or actions to take place
// based on the user's location in the game
enum ViewReplayStage {
  Start,
  HowToPlay,
  Countdown,
  Play,
  PlayAndRateForm,
  TimerExpires,
  ProvideScore,
  FormResults,
  ShowAllResults,
  ConsensusReached,
  NextSteps,
  Exit,
}

class ViewReplayBloc {
  /// ***********************************************************************
  /// Matches Bloc Constructor
  /// ***********************************************************************

  ViewReplayBloc({
    required this.gameMap,
    required this.gameMode,
    required this.groupID,
    required this.playerOneUserID,
    required this.judgeRequestID,}) {
    /// The method kicks off a running series of methods to set this page up
    setupViewReplayScreen();
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Setup variables to be passed in
  Map gameMap;
  String gameMode;
  String groupID;
  String playerOneUserID;
  UserPointOfView userPointOfView = UserPointOfView.Player;
  String judgeRequestID;

  /// Instantiate DB service objects so we can perform actions from a consolidated file
  DatabaseServices databaseService = DatabaseServices();

  /// The stream returns match document from playerOne point of view
  late Stream<QuerySnapshot> _matchesStream;
  MatchService matchService = MatchService();

  // Contains widgets that will be added to the view replay screen UI sink
  List<Widget> myWidgets = [];

  // GameInfo contains game related info (ex. player names, scores, title, etc)
  // cGameInfo is for higher level scope access
  late GameModel2 lgGameInfo;
  late GameModel2Extras lgGameInfoExtras;

  // Setup workout timer so they can be closed when dispose() is called
  late TimerService countdownTimer;
  late TimerService workoutTimer;
  late TimerService saveGameTimer;
  int cSaveGameTimer = 20; // max timeout for saving a video file, specifically, waiting for gameScreen stopRecording() method to generate an uploadURL

  // Store this user's userID and nickname
  late String userID = globals.dojoUser.uid;
  late String nickname = globals.nickname;

  // determines if a judging consensus was achieved
  bool consensus = false;
  int consensusScore = 0;

  // Setup other variables
  late String playerTwoUserID;
  int qaFormIndex = 0; // manage which form question to display
  int qaSetCount = 0; // for judges, manage when to display the next set of questions
  int qaQuestionsPerSet = 2; // how many questions are there for each set of questions?

  /// ***********************************************************************
  /// ***********************************************************************
  /// View Replay Configurations
  /// ***********************************************************************
  /// ***********************************************************************

  // Timers
  int cCountdownTimer = constants.cCountdownTimer; // pre workout countdown to start
  int cWorkoutTimer = constants.cWorkoutTimer; // workout duration. this should be refactored to dynamically obtain the time from the gameRules document

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

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams
  /// ***********************************************************************
  /// ***********************************************************************

  /// Contains all match details from database
  Stream<QuerySnapshot> get matchesStream => _matchesStream;

  /// Handles incoming events to signal UI changes (ex. the UI informs the stream something has happened)
  final _eventController = StreamController<ViewReplayStage>();
  Stream<ViewReplayStage> get eventStream => _eventController.stream;
  Sink<ViewReplayStage> get eventSink => _eventController.sink;

  /// Handles what should be displayed on UI (ex. since something happened, go do something like update the UI)
  final _uiController = StreamController<List<Widget>>();
  Stream<List<Widget>> get uiStream => _uiController.stream;
  Sink<List<Widget>> get uiSink => _uiController.sink;

  /// Manage P1 UI
  final _uiPlayerOne = StreamController<List<Widget>>();
  Stream<List<Widget>> get uiPlayerOneStream => _uiPlayerOne.stream;
  Sink<List<Widget>> get uiPlayerOneSink => _uiPlayerOne.sink;

  /// Manage P2 UI
  final _uiPlayerTwo = StreamController<List<Widget>>();
  Stream<List<Widget>> get uiPlayerTwoStream => _uiPlayerTwo.stream;
  Sink<List<Widget>> get uiPlayerTwoSink => _uiPlayerTwo.sink;

  /// Handle the game button's config: visibility, text, action
  final _buttonController = StreamController<Map>();
  Stream<Map> get buttonControllerStream => _buttonController.stream;
  Sink<Map> get buttonControllerSink => _buttonController.sink;

  /// Save Score stream
  final _saveScoreController = StreamController<String>();
  Stream<String> get saveScoreControllerStream => _saveScoreController.stream;
  Sink<String> get saveScoreControllerSink => _saveScoreController.sink;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  setupViewReplayScreen() async {
    setTimers(cCountdownTimer, cWorkoutTimer);

    // Create gameInfo object
    lgGameInfo = matchService.createGameObject(gameMap);
    lgGameInfoExtras = matchService.createGameExtrasObject(gameMap, playerOneUserID);

    // Start listening for stage events that controls what is displayed on the UI
    listenUiEventStream(lgGameInfo, lgGameInfoExtras);

    // Start the first stage of viewReplayStages
    eventSink.add(ViewReplayStage.Start);
  }

  void setTimers (int _countDownTimer, int _workoutTimer) {
    countdownTimer = TimerService(countdown: _countDownTimer);
    workoutTimer = TimerService(countdown: _workoutTimer);
  }

  void dispose() {
    printBig('dispose called on view replay bloc', 'true');
    _eventController.close();
    _buttonController.close();
    _uiController.close();
    _uiPlayerOne.close();
    _uiPlayerTwo.close();
  }


  /// ***********************************************************************
  /// ***********************************************************************
  /// Timer Widgets
  /// ***********************************************************************
  /// ***********************************************************************

  /// This is the 10,9,8... 3,2,1 Go countdown
  /// which plays before the workout starts
  void buildCountdown({required ViewReplayStage nextStage}) {
    countdownTimer.startTimer();

    countdownTimer.timeStream.listen((int _count) {
      if (_count == 0) {
        eventSink.add(nextStage);
      } else {
        List<Widget> _myWidgets = [];
        _myWidgets.add(
          HostCard(
            headLine: 'Get Ready Countdown',
            bodyText: '$_count',
            loud: false,
            variation: 3,
            transparency: true,
          ),
        );

        buildCountdownSFX(_count);
        uiSink.add(_myWidgets);
      }
    });
  }

  /// This is the workout timer
  void buildGameTimer({required int gameDuration, required nextStage}) {
    workoutTimer.startTimer();

    workoutTimer.timeStream.listen((int _count) {
      if (_count >= 0) {
        /// Update timer with new count
        List<Widget> _myWidgets = [];
        _myWidgets.add(ViewReplayHud(timer: _count, playerOneNickname: '${lgGameInfo.playerNicknames[lgGameInfoExtras.playerOneUserID]}'));
        uiSink.add(_myWidgets);
      }

      // && userPointOfView == UserPointOfView.Player
      if (_count <= 0) {
        eventSink.add(ViewReplayStage.TimerExpires);
      }
    });
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Input Field
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

  /// this function is passed into the score input field button onPress
  // on tap of "save score" button, the following events take place
  saveScoreButtonAction() async {
    /// User just tapped save button, so display a "Saving" or "Loading" type message
    // add to widgetList: host card with "saving video..." message
    myWidgets = [];
    myWidgets.add(buildSavingDescription());
    uiSink.add(myWidgets);

    /// has consensus score been reached?

    /// Save data
    await saveGameData();

    /// Was consensus met?
    if (consensus) {
      eventSink.add(ViewReplayStage.ConsensusReached);
    } else {
      eventSink.add(ViewReplayStage.NextSteps);
    }
  }

  /// This houses all logic of when and where to save game data to firebase
  Future<void> saveGameData() async {
    /// ***********************************************************************
    /// Save Data for King of the Hill
    /// ***********************************************************************
    if (gameMode == 'king of the hill') {
      printBig('saving', '$judgeRequestID');

      /// Get latest judge document
      Map judgeDoc = await databaseService.getJudge(id: judgeRequestID);

      /// update with score and user
      Map judgeScores = Map.from(judgeDoc['judgeScores']);
      judgeScores[lgGameInfoExtras.playerOneUserID] = lgGameInfo.playerScores[lgGameInfoExtras.playerOneUserID];
      judgeDoc['judges'].add(lgGameInfoExtras.playerOneUserID);

      /// Save judging score and just user ID to existing judging2 doc
      databaseService.updateJudgingWithScore(
        judgeScores: judgeScores,
          judges: judgeDoc['judges'],
          id: judgeRequestID,
      );

      /// Have we reached consensus?
      // judgeScores contains 3 scores that are the same
      Map winningJudges = getWinningJudges(judgeScores);

      /// If we have consensus, then do the following
      if (consensus) {
        printBig('consensusMet', 'true');
        printBig('winning judges', '$winningJudges');
        // if score = consensus...
        // - judges2: consensus score = score
        // - judges2: status = closed
        databaseService.updateJudgingWithConsensus(consensusScore: consensusScore, id: judgeRequestID);

        /// Update matchesAll2
        // with new score
        // with cPlayerGameOutcomeConfirmed
        // with date playerScoreUpdated
        lgGameInfo.playerScores[playerOneUserID] = consensusScore;
        lgGameInfo.playerGameOutcomes[playerOneUserID] = constants.cPlayerGameOutcomeConfirmed;
        lgGameInfo.dates[constants.cPlayersScoreUpdated] = DateTime.now();
        databaseService.updateMatchesFlat(lgGameInfo, lgGameInfoExtras);

        /// update leaderboard
        // with the consensus score
        Map leaderboardMap = await databaseService.getLeaderboard(gameID: lgGameInfo.id);
        String leaderboardID = leaderboardMap['id'];
        databaseService.updateLeaderboard(gameInfo: lgGameInfo, gameInfoExtras: lgGameInfoExtras, leaderboardID: leaderboardID);

        /// Send rewards to judges
        payWinningJudges(winningJudges);
      }
    }
  }
// fetch the addresses
  List winningJudgeEthereumAddresses = [
    '0x923C5D0e6A3a11A798aD3F05B16c7C715D1Bac38',
    '0x4c64942A929ecb23A9645872B655686a77D98586',
    '0x23Ab3FF6822b7EC93277d1C2E0A04E193C66a385',
  ];

  Map getWinningJudges(judgeScores) {
    // find the judgeScores that contains 3 scores that are the same
    Map groupedScores = {};

    for (var k in judgeScores.keys) {
      // print("Key : $k, value : ${judgeScores[k]}");

      // tally up number of times each number appears
      if(!groupedScores.containsKey(judgeScores[k])) {
        groupedScores[judgeScores[k]] = 1;
      } else {
        groupedScores[judgeScores[k]] +=1;
      }
    }

    // determine which number map key exceeds a count of 3
    // because that number is the correct score
    int consensusCountAppearances = 3;
    consensusScore = 0;
    for (var k in groupedScores.keys) {
      // print("Key : $k, value : ${judgeScores[k]}");
      if (groupedScores[k] >= consensusCountAppearances) {
        consensusCountAppearances = groupedScores[k];
        consensusScore = k;
        consensus = true;
      }
    }



    print(consensusScore); // this is the correct score
    print(consensusCountAppearances); // this is the number of times this score appears

    // build a map of the winning judges
    Map judgeWinners = {};
    for (var k in judgeScores.keys) {
      // print("Key : $k, value : ${judgeScores[k]}");

      if (judgeScores[k] == consensusScore) {
        judgeWinners[k] = judgeScores[k];
      }

    }
    print(judgeWinners);
    return judgeWinners;
  }

  payWinningJudges(Map winningJudges){
    Web3Service web3Service = Web3Service();

    int index = 0;
    for (var k in winningJudges.keys) {
      web3Service.sendEthereumTransaction(toAddress: winningJudgeEthereumAddresses[index]);
      index = index + 1;
    }
  }

  /// *********************************************************************

  GameModel2 setPlayerScoreToGameObject(GameModel2 gameInfo, GameModel2Extras gameInfoExtras, String scoreInputFieldValue) {
    gameInfo.playerScores[gameInfoExtras.playerOneUserID] = int.parse(scoreInputFieldValue);
    return gameInfo;
  }

  void checkForScoreConsensus(){}

  /// Close the judge request status to closed, in judge collection
  void qaCloseJudgingRequest(String judgeRequestID) {
    databaseService.closeJudgingRequest(judgeRequestID, userID, nickname);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Manage game stages, what to show, and what to do on the GameScreen UI
  /// ***********************************************************************
  /// ***********************************************************************

  /// This is called when a new event is added to eventSink of _uiController
  listenUiEventStream(GameModel2 gameInfo, GameModel2Extras gameInfoExtras) {
    eventStream.listen((ViewReplayStage event) {
      /// ***************************************************************
      ///                 STAGE: START
      /// ***************************************************************
      /// When viewReplay screen loads, start the 10s countdown timer
      if (event == ViewReplayStage.Start) {
        event = ViewReplayStage.HowToPlay;
      }

      /// ***************************************************************
      ///                STAGE: INSTRUCTIONS HOW TO PLAY
      /// ***************************************************************
      /// Stage = Game timer expires

      if (event == ViewReplayStage.HowToPlay) {
        Timer(Duration(milliseconds: 100), () {
          /// manage button visibility, text, and onPress actions

          HostCard hostCardIntro1 = HostCard(
            headLine: 'Count the number of pushup reps',
            bodyText: 'You\'ll earn 10 Dojo tokens for providing the same score as several other judges',
            transparency: true,
          );

          // default buttonConfig
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Start judging',
            'onPressButtonAction': ViewReplayStage.Countdown,
          };

          myWidgets.add(hostCardIntro1);
          uiSink.add(myWidgets);
          buttonControllerSink.add(buttonConfig);
        });
      }

      /// ***************************************************************
      ///                STAGE: COUNTDOWN
      /// ***************************************************************
      /// Stage = 10,9...3,2,1 countdown to start
      if (event == ViewReplayStage.Countdown) {

        /// clear the list so the view removes previous widgets
        myWidgets = [];
        uiSink.add(myWidgets);

        /// Display the 10,9...3,2,1 countdown
        // When timer service reaches 0, it auto starts the GameStage passed into this function
        buildCountdown(nextStage: ViewReplayStage.Play);
      }

      /// ***************************************************************
      ///               STAGE: Game Timer Starts
      /// ***************************************************************
      /// Stage = Game in progress so show the game timer

      if (event == ViewReplayStage.Play) {
        /// Clear the list so the view removes previous widgets
        myWidgets = [];

        /// Display game timer
        // When timer reaches 0, it auto starts the next game stage
        // passes gameDuration so it knows when to show GO GO GO message
        // passes Game stage to load when timer reaches 0
        buildGameTimer(gameDuration: cWorkoutTimer, nextStage: ViewReplayStage.TimerExpires);
      }

      /// ***************************************************************
      ///                STAGE: PLAY TIMER EXPIRES
      /// ***************************************************************
      /// Stage = Game timer expires

      if (event == ViewReplayStage.TimerExpires) {
        Timer(Duration(milliseconds: 1), () {
          /// manage button visibility, text, and onPress actions

          // default buttonConfig
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Next',
            'onPressButtonAction': ViewReplayStage.ProvideScore,
          };

          buttonControllerSink.add(buttonConfig);
        });
      }

      /// ***************************************************************
      ///                STAGE: Collect Score Input field
      /// ***************************************************************
      if (event == ViewReplayStage.ProvideScore) {

        /// start listening to the score input field values
        listenToScoreInputField();

        /// clear the list so the view removes previous widgets
        myWidgets = [];
        uiSink.add(myWidgets);

        /// Collect players rep count
        Timer(Duration(milliseconds: 500), () {
          myWidgets.add(buildSaveScoreDescription());

          /// Display Save score form and button with actions
          myWidgets.add(buildSaveGameScoreForm(saveScoreInputFieldAction,saveScoreButtonAction));

          /// add widgets to game screen view
          uiSink.add(myWidgets);
        });
      }

      /// ***************************************************************
      ///                STAGE: Consensus reached
      /// ***************************************************************
      if (event == ViewReplayStage.ConsensusReached) {

        /// Clear widgets from game screen
        myWidgets = [];
        uiSink.add(myWidgets);

        /// Build host chat cards and display on UI
        int timerDuration = 500;
        /// Collect players rep count
        Timer(Duration(milliseconds: 500), () {
          myWidgets.add(buildJudgeConsensusReached());

          /// add widgets to game screen view
          uiSink.add(myWidgets);
        });

        Timer(Duration(milliseconds: timerDuration), () {
          /// Manage button visibility and text
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Exit',
            'onPressButtonAction': ViewReplayStage.Exit,
          };
          buttonControllerSink.add(buttonConfig);
        });
      }

      /// ***************************************************************
      ///                STAGE: Next Steps
      /// ***************************************************************
      /// Stage = Let the player what they should do next
      if (event == ViewReplayStage.NextSteps) {

        /// Clear widgets from game screen
        myWidgets = [];
        uiSink.add(myWidgets);

        /// Build host chat cards and display on UI
        int timerDuration = 500;
        /// Collect players rep count
        Timer(Duration(milliseconds: 500), () {
          myWidgets.add(buildJudgeNextSteps());

          /// add widgets to game screen view
          uiSink.add(myWidgets);
        });

        Timer(Duration(milliseconds: timerDuration), () {
          /// Manage button visibility and text
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Exit',
            'onPressButtonAction': ViewReplayStage.Exit,
          };
          buttonControllerSink.add(buttonConfig);
        });
      }

    });
  }
}