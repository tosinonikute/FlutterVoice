import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_summary/layers/blocs/theme_bloc/theme_bloc.dart';
import 'package:voice_summary/layers/services/audio_recording_service.dart';
class SettingsScreen extends StatelessWidget {
   SettingsScreen({super.key});
  final _recordingService = AudioRecordingService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Appearance',
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme'),
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  context.read<ThemeBloc>().add(ThemeEvent());
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //     content: Text('Theme switching coming soon...'),
                  //   ),
                  // );
                },
              ),
              // const Divider(),
              // ListTile(
              //   title: const Text('Accent Color'),
              //   subtitle: const Text('Choose your preferred color'),
              //   trailing: Container(
              //     width: 24,
              //     height: 24,
              //     decoration: BoxDecoration(
              //       color: Theme.of(context).colorScheme.primary,
              //       shape: BoxShape.circle,
              //     ),
              //   ),
              //   onTap: () {
              //     // TODO: Implement color picker
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       const SnackBar(
              //         content: Text('Color picker coming soon...'),
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Storage',
            children: [
              ListTile(
                title: const Text('Clear Cache'),
                subtitle: const Text('Free up storage space'),
                trailing: const Icon(Icons.delete_outline),
                onTap: () async {
                  // TODO: Implement cache clearing
                  await _recordingService.removeAllRecordings();  
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Cache cleared successfully')),
                  // );
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Storage Location'),
                subtitle: const Text('Internal Storage'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Implement storage location selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Storage location selection coming soon...',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'About',
            children: [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              const Divider(),
              ListTile(
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Implement privacy policy
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy policy coming soon...'),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Implement terms of service
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Terms of service coming soon...'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(10),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }
}
