import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:voice_summary/layers/services/audio_player_service.dart';
import 'package:voice_summary/layers/services/audio_recording_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual data from your storage/database
    final List<HistoryItem> historyItems = [
      HistoryItem(
        id: '1',
        title: 'Meeting Notes',
        date: DateTime.now().subtract(const Duration(days: 1)),
        duration: const Duration(minutes: 5, seconds: 30),
        summary:
            'Discussed project timeline and deliverables. Team agreed on the new feature implementation schedule.',
        audioPath: '/path/to/audio1.wav',
      ),
      HistoryItem(
        id: '2',
        title: 'Interview Notes',
        date: DateTime.now().subtract(const Duration(days: 2)),
        duration: const Duration(minutes: 15, seconds: 45),
        summary:
            'Interview with candidate John Doe. Discussed experience in Flutter development and previous projects.',
        audioPath: '/path/to/audio2.wav',
      ),
      // Add more sample items as needed
    ];
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          actions: [
        
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Implement search functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search coming soon...')),
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Summaries'),
              Tab(text: 'Recordings'),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            historyItems.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No recordings yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your recorded audio summaries will appear here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: historyItems.length,
                  itemBuilder: (context, index) {
                    final item = historyItems[index];
                    return _HistoryItemCard(item: item);
                  },
                ),

            historyItems.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(50),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No recordings yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your recorded audio summaries will appear here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(70),
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: historyItems.length,
                  itemBuilder: (context, index) {
                    final item = historyItems[index];
                    return _HistoryItemCard(item: item);
                  },
                ),
            RecordingsPage(
            
            ),
          ],
        ),
      ),
    );
  }
}

class RecordingsPage extends StatefulWidget {
  const RecordingsPage({super.key,});
  @override
  State<RecordingsPage> createState() => _RecordingsPageState();
}

class _RecordingsPageState extends State<RecordingsPage> {
  List<String> recordings = [];
  final audioPlayer = AudioPlayerService();
  String? currentPlayingPath;
  bool _isLoading = true;
  Duration? _currentDuration;

  Future<List<String>> getRecordings() async {
    try {
      final result = await AudioRecordingService().getRecordings();
      setState(() {
        recordings = result;
        _isLoading = false;
      });
      return recordings;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    getRecordings();
    // Listen for playback completion
    // audioPlayer.audioPlayer.onPlayerComplete.listen((_) {
    //   setState(() {
    //     currentPlayingPath = null;
    //   });
    // });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> togglePlayback(String path) async {
    try {
      if (audioPlayer.isPlaying() && currentPlayingPath == path) {
        await audioPlayer.pause();
        setState(() {
          currentPlayingPath = null;
        });
      } else if (currentPlayingPath == path) {
        await audioPlayer.resume();
        setState(() {
          currentPlayingPath = path;
        });
      } else {
        if (audioPlayer.isPlaying()) {
          await audioPlayer.stop();
        }
        await audioPlayer.play(path);
        _currentDuration = await audioPlayer.getCurrentDuration();
        setState(() {
          currentPlayingPath = path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: ${e.toString()}')),
      );
    }
  }
  String? _selectedItem;
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recordings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic_off,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No recordings yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Your recorded audio files will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: recordings.length,
      itemBuilder: (context, index) {
        final item = recordings[index];
        final isCurrentItem = currentPlayingPath == item;
      
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          color: _selectedItem == item ? Theme.of(context).colorScheme.primary.withAlpha(70) : null,
          child: ListTile(
            leading: Icon(Icons.audio_file),
            title: Text(item.split('/').last),
            onLongPress: () { 
              setState(() {
                _selectedItem = item;
              });
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  title: Text('Delete Recording'),
                  content: Text('Are you sure you want to delete this recording?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        context.pop();
                        setState(() {
                          _selectedItem = null;
                        });
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pop();
                        AudioRecordingService().removeRecording(item);
                        setState(() {
                          recordings.removeAt(index);
                        });
                      },
                      child: Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            trailing: IconButton(
              icon: Icon(
                isCurrentItem && audioPlayer.isPlaying()
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
              onPressed: () {
                // togglePlayback(item)
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => StatefulBuilder(
                    builder: (context, setStateAgain) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      title: Text(item.split('/').last),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [                            
                          Center(
                            child: StreamBuilder<Duration>(
                              stream: audioPlayer.position,
                              builder: (context, snapshot) {
                                final position = snapshot.data;
                                if (position == null ||
                                    _currentDuration == null) {
                                  return const SizedBox.shrink();
                                }
                            
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LinearProgressIndicator(
                                      value: _currentDuration != null && _currentDuration!.inSeconds > 0
                                          ? (position.inSeconds.toDouble() / _currentDuration!.inSeconds.toDouble()).clamp(0.0, 1.0)
                                          : 0.0,
                                      color: Theme.of(context).colorScheme.primary,
                                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(20),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatDuration(position)} / ${_formatDuration(_currentDuration!)}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          
                            children: [
                              StreamBuilder<bool>(
                                stream: Stream.periodic(const Duration(milliseconds: 100))
                                    .map((_) => audioPlayer.isPlaying()),
                                builder: (context, snapshot) {
                                  final isPlaying = snapshot.data ?? false;
                                  return IconButton(
                                    onPressed: () {
                                      togglePlayback(item);
                                      setState(() {}); // Trigger rebuild of dialog
                                    },
                                    icon: CircleAvatar(
                                      child: Icon(
                                        isPlaying ? Icons.pause : Icons.play_arrow,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    currentPlayingPath = null;
                                    audioPlayer.stop();
                                  });
                                  context.pop();
                                },
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
         
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class _HistoryItemCard extends StatelessWidget {
  final HistoryItem item;

  const _HistoryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      elevation: 0.2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              item.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              DateFormat('MMM d, y • h:mm a').format(item.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatDuration(item.duration),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    // TODO: Implement audio playback
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Audio playback coming soon...'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.summary,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Implement re-summarize functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Re-summarizing...')),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Re-summarize'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Implement share functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share coming soon...')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class HistoryItem {
  final String id;
  final String title;
  final DateTime date;
  final Duration duration;
  final String summary;
  final String audioPath;

  HistoryItem({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    required this.summary,
    required this.audioPath,
  });
}
