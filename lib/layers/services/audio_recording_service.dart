import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:logger/logger.dart';

class AudioRecordingService {
  final _audioRecorder = AudioRecorder();
  final _logger = Logger();
  final _recordingStoppedController = StreamController<String?>.broadcast();
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isPaused = false;
  String? _currentRecordingPath;
  // Timer? _amplitudeTimer;
  // static const double _minAmplitude = 0.0; // dB
  // static const int _silenceDuration = 3; // seconds
  // int _silenceCounter = 0;

  Stream<String?> get onRecordingStopped => _recordingStoppedController.stream;
  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  String? get currentRecordingPath => _currentRecordingPath;

  String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(
      10,
      (index) => chars[random.nextInt(chars.length)],
      growable: false,
    ).join();
  }

  Future<void> _initialize() async {
    if (!_isInitialized) {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Microphone permission not granted');
      }
      _isInitialized = true;
    }
  }

  // void _startAmplitudeMonitoring() {
  //   _amplitudeTimer?.cancel();
  //   _silenceCounter = 0;
    
  //   _amplitudeTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
  //     if (!_isRecording || _isPaused) {
  //       timer.cancel();
  //       return;
  //     }

  //     try {
  //       final amplitude = await _audioRecorder.getAmplitude();
  //       _logger.d('Current amplitude: ${amplitude.current} dB');

  //       if (amplitude.current < _minAmplitude) {
  //         _silenceCounter++;
  //         _logger.d('Silence detected: $_silenceCounter seconds');
          
  //         if (_silenceCounter >= _silenceDuration) {
  //           _logger.i('Silence threshold reached, stopping recording');
  //           timer.cancel();
  //           await stopRecording();
  //         }
  //       } else {
  //         // Reset silence counter if sound is detected
  //         _silenceCounter = 0;
  //       }
  //     } catch (e) {
  //       _logger.e('Error checking amplitude: $e');
  //     }
  //   });
  // }

  Future<void> startRecording() async {
    try {
      await _initialize();
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 128000,
        ),
        path: path,
      );
      _logger.i('Started recording at: $path');
      _isRecording = true;
      _currentRecordingPath = path;
      // _startAmplitudeMonitoring();
    } catch (e) {
      _logger.e('Error starting recording: $e');
      _isRecording = false;
      _currentRecordingPath = null;
      rethrow;
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      // _amplitudeTimer?.cancel();
      final path = await _audioRecorder.stop();
      _logger.i('Stopped recording at: $path');
      _isRecording = false;
      _isPaused = false;
      // _silenceCounter = 0;
      _recordingStoppedController.add(path);
      return path;
    } catch (e) {
      _logger.e('Error stopping recording: $e');
      _isRecording = false;
      _isPaused = false;
      _currentRecordingPath = null;
      rethrow;
    }
  }

  Future<void> pauseRecording() async {
    if (!_isRecording || _isPaused) return;

    try {
      // _amplitudeTimer?.cancel();
      await _audioRecorder.pause();
      _logger.i('Paused recording');
      _isPaused = true;
    } catch (e) {
      _logger.e('Error pausing recording: $e');
      rethrow;
    }
  }

  Future<void> resumeRecording() async {
    if (!_isRecording || !_isPaused) return;

    try {
      await _audioRecorder.resume();
      _logger.i('Resumed recording');
      _isPaused = false;
      // _startAmplitudeMonitoring();
    } catch (e) {
      _logger.e('Error resuming recording: $e');
      rethrow;
    }
  }

  Future<void> removeRecording(String? path) async {
    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          _logger.i('Removed recording at: $path');
        }
      } catch (e) {
        _logger.e('Error removing recording: $e');
      }
    }
  }

  Future<void> saveRecording(String path, String title) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savedPath = '${directory.path}/$title.wav';
      final file = File(path);
      await file.copy(savedPath);
      _logger.i('Saved recording to: $savedPath');
      await removeRecording(path);
    } catch (e) {
      _logger.e('Error saving recording: $e');
      rethrow;
    }
  }

  Future<void> removeAllRecordings() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = await Directory(directory.path).list(recursive: true).toList();
    for (var file in files) {
      await File(file.path).delete();
    }
  }

  Future<void> dispose() async {
    // _amplitudeTimer?.cancel();
    if (_isRecording) {
      await stopRecording();
    }
    await _audioRecorder.dispose();
    await _recordingStoppedController.close();
  }

  /// get all recordings
  Future<List<String>> getRecordings() async {
    final directory = await getApplicationDocumentsDirectory();
    // check for only the wav files in the directory
    final files = Directory(directory.path).list(recursive: true,).where((element) => element.path.endsWith('.wav'));
    return files.map((e) => e.path).toList();
  }
}
