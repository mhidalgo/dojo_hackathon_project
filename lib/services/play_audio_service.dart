import 'package:just_audio/just_audio.dart';

/// How to use
// 1. Instantiate new object and pass in audio asset:
// - PlayAudio introMusic = PlayAudio(audioToPlay: 'assets/audio/formula1_song_1st_half.mp3');
// 2. Play Audio: introMusic.play()
// - at end of playing, the object auto closes itself
// 3. Call object.dispose in dispose method: introMusic.dispose()
// - the object auto disposes itself when the audio is playing so it's not critical you call dispose in the calling class's dispose method
// - but, you should call object.dispose if the audio track is longer than 10 seconds. If you don't dispose it, the audio will continue playing
// - after they navigate away from the current screen or to another app, until the audio track completes.

// Optional
// Prematurely stop audio: introMusic.stop()

class PlayAudio {
  PlayAudio({this.audioToPlay = '/assets/audio/moo.mp3' });
  String audioToPlay;

  // instantiate player object with just_audio class
  AudioPlayer player = AudioPlayer();

  // mount the audio asset to play
  set () async {
    await player.setAsset(audioToPlay);
  }

  // mount the audio asset to play
  // play asset, then dispose it
  play () async {
    await player.setAsset(audioToPlay);
    //player.setVolume(100.0);
    await player.play();
    dispose();
  }

  stop () async {
    await player.stop();
  }

  void dispose() async {
    await player.stop();
    player.dispose();
  }
}