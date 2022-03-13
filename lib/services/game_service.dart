import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/play_audio_service.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:dojo_app/widgets/timer_card.dart';

/// Game Service:
// handles any functions that are used by the game screen or view replay screen

class GameService {
  // Initialize DB object with methods to call DB
  // DatabaseServices databaseServices = DatabaseServices();

  /// Constructor
  GameService() {
    //
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Timer Widgets
  /// ***********************************************************************
  /// ***********************************************************************

  /// This is the 10,9,8... 3,2,1 Go countdown
  /// which plays before the workout starts
  void buildCountdown(nextStage, countdownTimer, eventSink, myWidgets, gameScreenUISink) {
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
  void buildGameTimer(int gameDuration, nextGameStage, workoutTimer, eventSink, myWidgets, gameScreenUISink) {
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

  void buildCountdownSFX(_countdown) {
    /// play countdown SFX
    PlayAudio countdownBeep = PlayAudio(audioToPlay: 'assets/audio/f1_beep.mp3');
    countdownBeep.play();

    switch (_countdown) {
      case 5:
        {
          PlayAudio countdown5 = PlayAudio(audioToPlay: 'assets/audio/countdown_5.mp3');
          countdown5.play();
        }
        break;

      case 4:
        {
          PlayAudio countdown4 = PlayAudio(audioToPlay: 'assets/audio/countdown_4.mp3');
          countdown4.play();
        }
        break;

      case 3:
        {
          PlayAudio countdown3 = PlayAudio(audioToPlay: 'assets/audio/countdown_3.mp3');
          countdown3.play();
        }
        break;

      case 2:
        {
          PlayAudio countdown2 = PlayAudio(audioToPlay: 'assets/audio/countdown_2.mp3');
          countdown2.play();
        }
        break;

      case 1:
        {
          PlayAudio countdown1 = PlayAudio(audioToPlay: 'assets/audio/countdown_1.mp3');
          countdown1.play();
        }
        break;

      default:
        {
          print("count: $_countdown");
        }
        break;
    }
  } // end buildCountdownSFX

  static bool isThisANewPersonalRecord({required int newScore, required int existingScore}){
    if (newScore > existingScore){
      return true;
    } else {
      return false;
    }
  }
}
