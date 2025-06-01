import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_summary/config/route/app_router.dart';
import 'package:voice_summary/config/theme/app_theme.dart';
import 'package:voice_summary/layers/blocs/summarize_bloc/summarize_bloc.dart';
import 'package:voice_summary/layers/blocs/theme_bloc/theme_bloc.dart';
import 'package:voice_summary/layers/services/models/app_theme.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider(create: (context) => SummarizeBloc()),
      ],
      child: Builder(
        builder: (context) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return MaterialApp.router(
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode:
                    state.appTheme == AppThemeMode.light
                        ? ThemeMode.light
                        : state.appTheme == AppThemeMode.dark
                        ? ThemeMode.dark
                        : ThemeMode.system,
                routerConfig: router,
                debugShowCheckedModeBanner: false,
                
                builder: FlutterSmartDialog.init(
                  toastBuilder: (message) => Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message),
                  ),
                  notifyStyle: FlutterSmartNotifyStyle(
                    
                    failureBuilder: (message) =>Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(message,style: Theme.of(context).textTheme.bodyMedium,),
                          const SizedBox(height: 16,),
                          Icon(Icons.error,color: Theme.of(context).colorScheme.primary,),
                        ],
                      ),
                    ),
                    alertBuilder: (message) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(message,style: Theme.of(context).textTheme.bodyMedium,),
                          const SizedBox(height: 16,),
                          Icon(Icons.error,color: Theme.of(context).colorScheme.primary,),
                        ],
                      ),
                    ),
                    errorBuilder: (message) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                      
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(message,style: Theme.of(context).textTheme.bodyMedium,),
                          const SizedBox(height: 16,),
                          Icon(Icons.error,color: Theme.of(context).colorScheme.primary,),
                        ],
                      ),
                    ),
                    successBuilder: (message) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(message,style: Theme.of(context).textTheme.bodyMedium,),
                          const SizedBox(height: 16,),
                          Icon(Icons.check,color: Theme.of(context).colorScheme.primary,),
                        ],
                      ),
                    ),
                    warningBuilder: (message) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(message,style: Theme.of(context).textTheme.bodyMedium,),
                          const SizedBox(height: 16,),
                          Icon(Icons.warning,color: Colors.yellow,),
                        ],
                      ),
                    ),
                  
                  ),
                  loadingBuilder: (message) => Container(
                    padding: const EdgeInsets.all(16),
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(message,style: Theme.of(context).textTheme.bodyMedium,),
                        const SizedBox(height: 16,),
                        SpinKitFadingCircle(
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
