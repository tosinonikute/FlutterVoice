import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:voice_summary/config/route/route_name.dart';
import 'package:voice_summary/layers/blocs/summarize_bloc/summarize_bloc.dart';
import 'package:voice_summary/layers/services/audio_recording_service.dart';
import 'package:voice_summary/core/widgets/app_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioRecordingService _recordingService = AudioRecordingService();
  Timer? _timer;
  Duration _recordingDuration = Duration.zero;
  bool _isRecording = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _setupRecordingListener();
  }

  void _setupRecordingListener() {
    // Listen for recording state changes
    _recordingService.onRecordingStopped.listen((path) async {
      if (mounted && path != null) {
        // Reset recording states
        setState(() {
          _isRecording = false;
          _isPaused = false;
          _recordingDuration = Duration.zero;
        });
        _stopTimer();

        // Start transcription
        context.read<SummarizeBloc>().add(
          ConvertAudioToTextEvent(
            audioPath: path,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordingService.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration += const Duration(seconds: 1);
      });
    });
    
  }
 
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _toggleRecording() async {
    try {
      if (!_isRecording) {
        await _recordingService.startRecording();
        setState(() {
          _isRecording = true;
          _isPaused = false;
        });
        _startTimer();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Recording started...')));
        }
      } else {
        final path = await _recordingService.stopRecording();
        if (mounted) {
          // Reset recording states
          setState(() {
            _isRecording = false;
            _isPaused = false;
            _recordingDuration = Duration.zero;
          });
          _stopTimer();

          if (path != null) {
            // Start transcription immediately
            context.read<SummarizeBloc>().add(
              ConvertAudioToTextEvent(
                audioPath: path,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: Failed to save recording'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _togglePause() async {
    if (_isPaused) {
      await _recordingService.resumeRecording();
      setState(() {
        _isPaused = false;
      });
      _startTimer();
    } else {
      await _recordingService.pauseRecording();
      setState(() {
        _isPaused = true;
      });
      _stopTimer();
    }
  }

  void showLoading(String message) async {
    SmartDialog.show(
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.3,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SpinKitFadingCircle(
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SummarizeBloc, SummarizeState>(
      listener: (context, state) {
        print(state);
        if (state is ConvertingAudioToText) {
          showLoading("Converting audio to text...");
        }
        if (state is ConvertedAudioToTexxt) {
          SmartDialog.dismiss();
          context.pushNamed(RouteName.convertedResult, extra: state.text);
        }

        if (state is ConvertTextError) {
          SmartDialog.dismiss();
          SmartDialog.show(
            builder:
                (context) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.error,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const AppLogo(size: 20),
            actions: [
              // IconButton(
              //   onPressed: () {
              //     if (_isRecording) {
              //       _toggleRecording();
              //     }
              //     context.pushNamed(RouteName.history);
              //   },
              //   icon: const Icon(Icons.history),
              // ),
              IconButton(
                onPressed: () {
                  if (_isRecording) {
                    _toggleRecording();
                  }
                  context.pushNamed(RouteName.settings);
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    const Icon(Icons.info_outline),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Record your voice and get AI-powered summaries instantly',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mic_none,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(50),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isRecording ? 'Recording...' : 'Ready to Record?',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          _isRecording
                              ? 'Recording... Speak clearly into the microphone'
                              : 'Tap the button below to start recording your voice',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (_isRecording) ...[
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _formatDuration(_recordingDuration),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 40),
                              Column(
                                children: [
                                  // Text(
                                  //   'Recording will stop automatically after 3 seconds of silence',
                                  //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  //     color: Theme.of(context).colorScheme.onSurface,
                                  //   ),
                                  // ),
                                  // const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _toggleRecording,
                                    icon: const Icon(Icons.transcribe),
                                    label: const Text('Stop & Transcribe'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: !_isRecording ? _toggleRecording : null,
                    icon: const Icon(Icons.mic),
                    label: Text(
                      _isRecording ? 'Recording...' : 'Start Recording',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
