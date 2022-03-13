import 'package:dojo_app/models/game_model.dart';
import 'package:dojo_app/models/game_model2.dart';
import 'package:dojo_app/models/game_model2_extras.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/services/play_audio_service.dart';
import 'package:dojo_app/style/text_styles.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/custom_text_field.dart';
import 'package:dojo_app/widgets/form_judgment_card.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:dojo_app/widgets/loading_icon.dart';
import 'package:dojo_app/widgets/one_player_result_card.dart';
import 'package:dojo_app/widgets/personal_record_card.dart';
import 'package:dojo_app/widgets/tutorial_video.dart';
import 'package:dojo_app/widgets/versus_card.dart';
import 'package:dojo_app/widgets/game_score_form.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/constants.dart' as constants;

/// ***************************************************************
///           Build Widgets
/// ***************************************************************
/// These functions are used to build game_screen widgets.
/// They are separated into this file to make gameBloc easier to read
/// and to make the widget building more manageable

/// ***************************************************************
///  Intro Widgets: Levels
/// ***************************************************************

List buildIntro(GameModel2 gameInfo, GameModel2Extras gameInfoExtras) {
  List hostIntro = [];
  // Map scores = getScoresAndGoalsForLevels(gameInfo, gameInfoExtras);

  if (gameInfo.gameMode == 'levels') {
    Map scores = getScoresAndGoalsForLevels(gameInfo, gameInfoExtras);
    HostCard hostCardIntro1 = HostCard(
      headLine: 'Win by performing the most foul shots basketball shots',
      bodyText: 'Your goal is ${scores['thisUserPushupGoal']} pushups',
      transparency: true,
    );

    hostIntro.add(hostCardIntro1);
  }

  if (gameInfo.gameMode == 'king of the hill') {
    if (gameInfoExtras.opponentVideoAvailable == true) {
      HostCard hostCardIntro1 = HostCard(
        headLine: 'HOW TO PLAY',
        bodyText: 'Win by performing the most pushups in 60 seconds.',
        transparency: true,
      );

      HostCard hostCardIntro2 = HostCard(
        headLine: 'GOOD NEWS',
        bodyText: 'Your opponent has already completed their pushups.',
        transparency: true,
      );

      HostCard hostCardIntro3 = HostCard(
        headLineVisibility: false,
        bodyText: 'For motivation, I\'ll play their video while you compete.',
        transparency: true,
      );

      HostCard hostCardIntro4 = HostCard(
        headLineVisibility: false,
        bodyText: 'Afterwards, I\'ll send your video for their verification of your reps.',
        transparency: true,
      );

      hostIntro.add(hostCardIntro1);
      hostIntro.add(hostCardIntro2);
      hostIntro.add(hostCardIntro3);
      hostIntro.add(hostCardIntro4);

    } else {

      HostCard hostCardIntro1 = HostCard(
        headLine: 'HOW TO PLAY',
        bodyText: 'Win by performing the most PUSHUPS in 60 seconds.',
        transparency: true,
      );

      hostIntro.add(hostCardIntro1);
    }
  }
  return hostIntro;
}

List buildGetReady(GameModel2 gameInfo, GameModel2Extras gameInfoExtras) {
  List hostGetReady = [];
  Map scores = getScoresAndGoalsForLevels(gameInfo, gameInfoExtras);

  // get opponents nickname
  String opponentNickname = 'This opponent';
  gameInfo.playerNicknames.entries.forEach((e) {
    if (e.key != gameInfoExtras.playerOneUserID) {
      opponentNickname = e.value;
    }
  });

  if (gameInfo.gameMode == 'levels') {
    HostCard hostCardGetReady1 = HostCard(
      headLine: 'Meet your level ${gameInfo.level} Dojo boss',
      bodyText: '$opponentNickname is bringing their A game.',
      transparency: true,
    );

    HostCard hostCardGetReady2 = HostCard(
      headLine: 'Get Ready',
      bodyText: 'I\'ll give you a 10s countdown, then the 60s workout timer begins.',
      transparency: true,
    );

    HostCard hostCardGetReady3 = HostCard(
      headLineVisibility: false,
      bodyText: 'Reminder: Your goal is ${scores['thisUserPushupGoal']} pushups or more to defeat $opponentNickname',
      transparency: true,
    );

    hostGetReady.add(hostCardGetReady1);
    hostGetReady.add(hostCardGetReady2);
    hostGetReady.add(hostCardGetReady3);
  }

  if (gameInfo.gameMode == 'matches') {
    if (gameInfoExtras.opponentVideoAvailable == true) {
      HostCard hostCardGetReady1 = HostCard(
        headLine: 'Meet your opponent',
        bodyText: '$opponentNickname is bringing their A game.',
        transparency: true,
      );

      HostCard hostCardGetReady2 = HostCard(
        headLine: 'Get Ready',
        bodyText: 'I\'ll give you a 10s countdown, then the 60s workout timer begins.',
        transparency: true,
      );

      HostCard hostCardGetReady3 = HostCard(
        headLineVisibility: false,
        bodyText: 'Reminder: Your goal is to do MORE pushups than your opponent.',
        transparency: true,
      );

      hostGetReady.add(hostCardGetReady1);
      hostGetReady.add(hostCardGetReady2);
      hostGetReady.add(hostCardGetReady3);

    } else {

      HostCard hostCardGetReady1 = HostCard(
        headLine: 'Get Ready',
        bodyText: 'I\'ll give you a 10s countdown, then the 60s workout timer begins.',
        transparency: true,
      );

      HostCard hostCardGetReady2 = HostCard(
        headLineVisibility: false,
        bodyText: 'Reminder: Your goal is to do as many pushups as possible before times up.',
        transparency: true,
      );

      hostGetReady.add(hostCardGetReady1);
      hostGetReady.add(hostCardGetReady2);
    }
  }
  return hostGetReady;
}

List buildNextSteps(GameModel2 gameInfo, GameModel2Extras gameInfoExtras, youWin) {
  // method needs: playerNicknames, gameMode, opponentVideoAvailable (aka: game closed)
  // method needs: win/loss/tie,

  List hostNextSteps = [];

  // get opponents nickname
  String opponentNickname = 'This opponent';
  gameInfo.playerNicknames.entries.forEach((e) {
    if (e.key != gameInfoExtras.playerOneUserID) {
      opponentNickname = e.value;
    }
  });

  if (gameInfo.gameMode == 'levels') {
    String message;
    String title;

    if (youWin) {
      title = 'NEXT LEVEL UNLOCKED';
      message = 'Rest up, stay hydrated, and train. When you\'re ready, take on the next Dojo level to find out what you\'re capable of.';
    } else {
      title = 'Oh no. What a shame';
      message = 'Get back to training to build up your strength, and try again when you\'re physically and mentally ready';
    }

    HostCard hostCardNextSteps1 =  HostCard(
      headLine: title,
      bodyText: message,
      transparency: true,
    );

    hostNextSteps.add(hostCardNextSteps1);
  }

  if (gameInfo.gameMode == 'king of the hill') {
    HostCard hostCardNextSteps1 = HostCard(
      headLine: 'WAIT FOR THE JUDGES',
      bodyText: 'Human judges will review your video to validate number of pushups reps completed.' ,
      transparency: true,
    );
    HostCard hostCardNextSteps2 = HostCard(
      headLineVisibility: false,
      bodyText: 'At the end of the week, if you are the top player, you\'ll win your video performance as a DOJO NFT.' ,
      transparency: true,
    );
    hostNextSteps.add(hostCardNextSteps1);
    hostNextSteps.add(hostCardNextSteps2);
  }

  if (gameInfo.gameMode == 'matches') {
    if (gameInfoExtras.opponentVideoAvailable == true) {
      HostCard hostCardNextSteps1 = HostCard(
        headLine: 'WAIT FOR YOUR NEXT OPPONENT',
        bodyText: 'I\'ll let you know when the game masters set you up with your next match.',
        transparency: true,
      );

      HostCard hostCardNextSteps2 = HostCard(
        headLineVisibility: false,
        bodyText: 'In the meantime, rest up and keep training.',
        transparency: true,
      );

      hostNextSteps.add(hostCardNextSteps1);
      hostNextSteps.add(hostCardNextSteps2);

    } else {

      HostCard hostCardNextSteps1 = HostCard(
        headLine: 'WAITING ON $opponentNickname',
        bodyText: 'I informed your opponent you played and sent your video.',
        transparency: true,
      );

      HostCard hostCardNextSteps2 = HostCard(
        headLineVisibility: false,
        bodyText: 'When they complete their pushups, I\'ll let you know so you can watch to find out who wins and who loses.',
        transparency: true,
      );

      hostNextSteps.add(hostCardNextSteps1);
      hostNextSteps.add(hostCardNextSteps2);
    }
  }
  return hostNextSteps;
}

Widget buildSetupEnvironment() {
  return HostCard(
    headLine: 'Setup your space',
    bodyText: 'First, position your camera so you can see your entire body while performing the movement.',
    transparency: true,
  );
}

Widget buildTutorialDescription() {
  return HostCard(
    headLine: 'Pushup tutorial',
    bodyText: 'Here\'s a reminder on how to perform this type of pushup.',
    transparency: true,
  );
}

Widget buildPushupTestDescription() {
  return HostCard(
    headLine: 'Perform a couple test push-ups!',
    bodyText: 'Let\'s see your pushup and I\'ll let you know if it passes my strict standards.',
    transparency: true,
  );
}

Widget buildTutorialVideo({required String file}) {
  return TutorialVideo(gifAsset: file);
}

Widget buildGameTimeExpires() {
  return HostCard(
      headLineVisibility: false,
      bodyText: 'STOP!',
      transparency: true,
      loud: true);
}

Widget buildSaveScoreDescription() {
  return HostCard(
    headLine: 'Input # of Pushups',
    bodyText: 'How many reps did the player perform?',
    transparency: true,
  );
}

Widget buildJudgeNextSteps() {
  return HostCard(
    headLine: 'Thank you for judging',
    bodyText: 'We need more people to judge and reach a score consensus. If your score matches what others say, then we will deposit 100 DOJO tokens into your account. We will let you know!',
    transparency: true,
  );
}

Widget buildJudgeConsensusReached() {
  return HostCard(
    headLine: 'A consensus in score has been met!',
    bodyText: 'Several judges have agreed with the score you put in, so you and all the matching judges will receive 100 DOJO tokens',
    transparency: true,
  );
}

///New combined form and button for saving game score.  This was done to have validation.
Widget buildSaveGameScoreForm(saveScoreInputFieldAction, saveScoreButtonAction) {
  return GameScoreForm(
    inputLabel: 'Completed Reps',
    saveScoreInputFieldAction: saveScoreInputFieldAction,
    keyboardType: TextInputType.number,
    title: 'SAVE REPS',
    saveScoreButtonAction: saveScoreButtonAction,

  );
}

Widget buildSaveScoreInputField(saveScoreInputFieldAction) {
  return ShortScoreTextField(
      inputLabel: 'Completed Shots',
      onChangeAction: saveScoreInputFieldAction,
      keyboardType: TextInputType.number);
}

Widget buildSaveScoreButton(saveScoreButtonAction) {
  return MediumEmphasisButton(
    title: 'SAVE MY REPS',
    onPressAction: saveScoreButtonAction,
  );
}

Widget buildSavingDescription() {
  return Container(
      child: Column(
        children: [
          LoadingAnimatedIcon(),
          BodyText2Bold(text: 'Saving video and results...'),
        ],
      )
  );
}

Widget buildYourResultsDescription(gameMode) {
  String hostCardBody = 'Good Job!';

  if (gameMode == 'levels') {
    hostCardBody = 'On the next screen, find out if you have won or lost!';
  }

  return HostCard(
    headLine: 'Results Saved',
    bodyText: hostCardBody,
    transparency: true,
  );
}

Widget buildYourResultsCard({required String gameMode, required GameModel2 gameInfo, required GameModel2Extras gameInfoExtras}) {
  int playerScore = 0;

  // extract required data from gameInfo
  int score = gameInfo.playerScores[gameInfoExtras.playerOneUserID];
  int gameDuration = gameInfoExtras.gameDuration;

  playerScore = score;

  return OnePlayerResultsCard(
      score: playerScore,
      duration: gameDuration);
}

Widget buildPersonalRecord({required Map playerOneRecords, int thisGamesScore = 0}) {
  int personalRecord = 0;
  int score = 0;

  // extract required data from gameInfo
  if (playerOneRecords['personalRecordReps'] != null) {
    score = playerOneRecords['personalRecordReps'];
  }

  personalRecord = score;
  return PersonalRecordCard(personalRecordScore: personalRecord, thisGamesScore: thisGamesScore);
}

Widget buildQuestionFormResults({required Map qJudgeForm, required GameModel2 gameInfo, required GameModel2Extras gameInfoExtras}) {
  return FormJudgementCard(questions: qJudgeForm, gameInfo: gameInfo, gameInfoExtras: gameInfoExtras);
}

Widget buildAllResultsDescription() {
  return HostCard(
    headLine: 'Winner..',
    bodyText: 'And the winner is...',
    transparency: true,
  );
}

Widget buildAllResultsCardWithGameObject(GameModel2 gameInfo, GameModel2Extras gameInfoExtras) {
  String cardSubTitle = '';
  if (gameInfo.gameMode == 'levels') {
    cardSubTitle = 'LEVEL ${(gameInfo.level).toInt()}';
  }

  return VersusCard2(
    titleVisibility: true,
    displayAcceptLevelButton: false,
    cardTitle: '${gameInfoExtras.title}',
    cardSubTitle: cardSubTitle,
    playerOneName: '${gameInfo.playerNicknames[gameInfo.players[0]]}',
    playerOneAvatar: 'images/avatar-blank.png',
    playerOneScore: '${gameInfo.playerScores[gameInfo.players[0]]}',
    playerOneVideo: '',
    playerTwoName: '${gameInfo.playerNicknames[gameInfo.players[1]]}',
    playerTwoAvatar: 'images/avatar-blank.png',
    playerTwoScore: '${gameInfo.playerScores[gameInfo.players[1]]}',
    playerTwoVideo: '',
  );
}

Widget buildAllResultsCardWithMap(Map gameInfo) {
  String cardSubTitle = '';
  if (gameInfo['gameMode'] == 'levels') {
    cardSubTitle = 'LEVEL ${(gameInfo['level']).toInt()}';
  }

  return VersusCard2(
    titleVisibility: true,
    displayAcceptLevelButton: false,
    cardTitle: '${gameInfo['gameRules']['title']}',
    cardSubTitle: cardSubTitle,
    playerOneName: '${gameInfo['playerNicknames'][gameInfo['players'][0]]}',
    playerOneAvatar: 'images/avatar-blank.png',
    playerOneScore: '${gameInfo['playerSubScores'][gameInfo['players'][0]]['reps']}',
    playerOneVideo: '',
    playerTwoName: '${gameInfo['playerNicknames'][gameInfo['players'][1]]}',
    playerTwoAvatar: 'images/avatar-blank.png',
    playerTwoScore: '${gameInfo['playerSubScores'][gameInfo['players'][1]]['reps']}',
    playerTwoVideo: '',
  );
}

void buildCountdownSFX(_countdown) {
  /// play countdown SFX
  PlayAudio countdownBeep = PlayAudio(audioToPlay: 'assets/audio/f1_beep.mp3');

  switch (_countdown) {
    case 5:
      {
        // PlayAudio countdown5 = PlayAudio(audioToPlay: 'assets/audio/countdown_5.mp3');
        // countdown5.play();
        countdownBeep.play();
      }
      break;

    case 4:
      {
        // PlayAudio countdown4 = PlayAudio(audioToPlay: 'assets/audio/countdown_4.mp3');
        // countdown4.play();
        countdownBeep.play();
      }
      break;

    case 3:
      {
        PlayAudio countdown3 = PlayAudio(audioToPlay: 'assets/audio/countdown_3.mp3');
        countdown3.play();
        countdownBeep.play();
      }
      break;

    case 2:
      {
        PlayAudio countdown2 = PlayAudio(audioToPlay: 'assets/audio/countdown_2.mp3');
        countdown2.play();
        countdownBeep.play();
      }
      break;

    case 1:
      {
        PlayAudio countdown1 = PlayAudio(audioToPlay: 'assets/audio/countdown_1.mp3');
        countdown1.play();
         countdownBeep.play();
      }
      break;

    default:
      {
        print("count: $_countdown");
      }
      break;
  }
}

Widget buildYouWinOrLoseDescription(bool youWin) {
  String message;

  if (youWin) {
    message = 'YOU WIN';
  } else {
    message = 'YOU LOSE';
  }

  return HostCard(
    headLineVisibility: false,
    bodyText: message,
    transparency: true,
  );
}

Widget buildYouWinOrLoseOrTieDescription(Map playerGameOutcomes, String playerOneUserID) {
  String message;

  if (playerGameOutcomes[playerOneUserID] == constants.cPlayerGameOutcomeWin || playerGameOutcomes[playerOneUserID] == constants.cPlayerGameOutcomeWinByForfeit) {
    message = 'YOU WIN';
  } else if (playerGameOutcomes[playerOneUserID] == constants.cPlayerGameOutcomeLose || playerGameOutcomes[playerOneUserID] == constants.cPlayerGameOutcomeLoseByForfeit){
    message = 'YOU LOSE';
  } else {
    message = 'YOU TIE';
  }

  return HostCard(
    headLineVisibility: false,
    bodyText: message,
    transparency: true,
  );
}

/// ***************************************************************
/// ***************************************************************
///  Helper functions to build widgets
/// ***************************************************************
/// ***************************************************************
/// The functions are used by the build widgets

void playWinnerOrLoserSFX2({required String sfxTrackWin, required String sfxTrackLose, required playerGameOutcomes, required userID}) {
  if (playerGameOutcomes[userID] == constants.cPlayerGameOutcomeWin || playerGameOutcomes[userID] == constants.cPlayerGameOutcomeWinByForfeit) {
    if (sfxTrackWin != '0') {
      PlayAudio sfx = PlayAudio(audioToPlay: sfxTrackWin);
      sfx.play();
    }
  } else if (playerGameOutcomes[userID] == constants.cPlayerGameOutcomeLose || playerGameOutcomes[userID] == constants.cPlayerGameOutcomeLoseByForfeit) {
    if (sfxTrackLose != '0') {
      PlayAudio sfx = PlayAudio(audioToPlay: sfxTrackLose);
      sfx.play();
    }
  }
}

Map getScoresAndGoalsForLevels(GameModel2 gameInfo, GameModel2Extras gameInfoExtras) {
  String currentUserID = gameInfoExtras.playerOneUserID;
  Map playerScores = gameInfo.playerScores;
  int opponentPushupCount = 0;
  int pushupGoal = 0;

  // fetch the opponents score
  playerScores.entries.forEach((e) {
    if (e.key != currentUserID) {
      opponentPushupCount = e.value;
    }
  });

  // determine score this player needs to win
  pushupGoal = opponentPushupCount + 1;

  Map scores = {
    'opponentPushupScore': opponentPushupCount,
    'thisUserPushupGoal': pushupGoal,
  };

  return scores;
}