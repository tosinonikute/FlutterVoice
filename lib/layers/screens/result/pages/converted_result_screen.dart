import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:voice_summary/config/route/route_name.dart';
import 'package:voice_summary/layers/blocs/summarize_bloc/summarize_bloc.dart';


class ConvertedResultScreen extends StatelessWidget {
  const ConvertedResultScreen({super.key, required this.convertedText});
  final String convertedText;
    void showLoading(String message) async {
    SmartDialog.show(
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            // width: MediaQuery.of(context).size.width * 0.4,
            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.3),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(message, style: Theme.of(context).textTheme.bodyMedium,textAlign: TextAlign.center,),
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
        if (state is SummarizedText) {
          SmartDialog.dismiss();
          context.pushNamed(RouteName.summarizedResult, extra: state.summary);
        }
        if (state is SummarizingText) {
          showLoading("Summarizing text...");
        }
        if (state is SummarizeError) {
          SmartDialog.dismiss();
          SmartDialog.show(builder: (context) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error,color: Theme.of(context).colorScheme.error,),
                const SizedBox(height: 16,),
                Text(state.error,style: Theme.of(context).textTheme.bodyMedium,),
              ],
            ),
          ));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Result')),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                convertedText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  // color: Theme.of(context).colorScheme.onSurface.withAlpha(70),
                ),
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                context.read<SummarizeBloc>().add(SummarizeTextEvent(text: convertedText));
              },
              child: const Text('Summarize Now'),
            ),
          ),
        );
      },
    );
  }
}
