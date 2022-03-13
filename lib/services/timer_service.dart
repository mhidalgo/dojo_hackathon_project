import 'dart:async';

/// How to use this service:
/*
TimerService countdownTimer = TimerService(10);
countdownTimer.startTimer();
// listen to the stream that provides a new number every second
countdownTimer.timesStream.listen((int _count) {
  // do stuff
  // cancel timer early,
  // or let timer expire and it will auto dispose itself }
*/

class TimerService {
  TimerService({this.countdown = 10});

  Timer? _countdownTimer;
  int countdown; // timer starting position in seconds
  int _localCountDown = 3;
  final oneSec = const Duration(seconds: 1); //time interval to count by
  var myTimer;
  late Timer timer;

  /// StreamController to manage sending time out
  final _timerController = StreamController<int>();
  Stream<int> get timeStream => _timerController.stream;
  Sink<int> get timeSink => _timerController.sink;

  void dispose() {
    cancelTimer();
    _timerController.close();
  }

  startTimer() {
    _localCountDown = countdown;
    timer = Timer.periodic(oneSec, (timer) {
      timeSink.add(_localCountDown);
      _localCountDown--;
      if (_localCountDown == -1) {
        cancelTimer();
      }
    });
  }

  setCountdownToZero() {
    _localCountDown = -1;
  }

  int getRemainingTime() {
    return countdown;
  }

  cancelTimer() {
    try {
      //printBig('cancelTimer Function called', '$countdown timer');
      timer.cancel();
      //dispose();
    } catch (e) {
      //printBig('TIMER CANCEL ERROR FOR TIMER: $countdown', '$e');
    }
  }
}
