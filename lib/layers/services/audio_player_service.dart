import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class AudioPlayerService {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool _isInitialized = false;
  Duration? _currentDuration;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await audioPlayer.setLoopMode(LoopMode.off);
      _isInitialized = true;
    }
  }
  
  Future<void> play(String path) async {
    await _ensureInitialized();
    await audioPlayer.setFilePath(path);
    await audioPlayer.play();
    // Get duration after playing
    _currentDuration = await audioPlayer.duration;
  }

  Future<void> resume() async {
    await _ensureInitialized();
    await audioPlayer.play();
  }

  Future<void> pause() async {
    await _ensureInitialized();
    await audioPlayer.pause();
  }

  Future<void> stop() async {
    await _ensureInitialized();
    await audioPlayer.stop();
    _currentDuration = null;
  }
   /// get duration of the audio file
   Future<int> getDuration(String path) async {
     try {
       final player = AudioPlayer();
       await player.setFilePath(path);
       final duration = await player.duration;
       await player.dispose();
       return duration?.inSeconds ?? 0;
     } catch (e) {
       Logger().e('Error in getDuration: $e');
       return 0;
     }
   }
  // check if the audio is playing
  bool isPlaying() {
    return audioPlayer.playing;
  }

  Future<void> dispose() async {
    await audioPlayer.dispose();
    _isInitialized = false;
    _currentDuration = null;
  }
  // Future<Duration> seek(String path) async {
  //   return await audioPlayer.seek(Duration(seconds: 120)).then((value) => audioPlayer);
    
  // }
  Stream<Duration> get duration => audioPlayer.durationStream.map((d) => d ?? Duration.zero);
  
  Stream<Duration> get position => audioPlayer.positionStream;
  
  Future<Duration?> getCurrentDuration() async {
    _currentDuration ??= audioPlayer.duration;
    return _currentDuration;
  }
}
