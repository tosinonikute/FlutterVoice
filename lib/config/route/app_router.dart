import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voice_summary/config/route/route_name.dart';
import 'package:voice_summary/layers/screens/history/history_page.dart';
import 'package:voice_summary/layers/screens/home/pages/home_screen.dart';
import 'package:voice_summary/layers/screens/result/pages/converted_result_screen.dart';
import 'package:voice_summary/layers/screens/result/pages/result_screen.dart';
import 'package:voice_summary/layers/screens/result/pages/summarized_screen_result.dart';
import 'package:voice_summary/layers/screens/settings/pages/settings_screen.dart';
import 'package:voice_summary/layers/screens/welcome/onboarding_page/on_boarding_page.dart';
import 'package:voice_summary/layers/screens/welcome/splash_page/splash_page.dart';



GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();


enum Direction { right, left, top, bottom }

Page<dynamic> _customTransitionPage({
  required Widget child,
  Direction direction = Direction.right,
}) {
  return CustomTransitionPage(
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 100),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin:
                direction == Direction.right
                    ? const Offset(1.0, 0.0)
                    : direction == Direction.left
                    ? const Offset(-1.0, 0.0)
                    : direction == Direction.top
                    ? const Offset(0.0, -1.0)
                    : const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
  );
}
GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteName.splashPage,
    routes:[
      GoRoute(
        path: RouteName.splashPage,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: RouteName.onboarding,
        path: RouteName.onboarding,
        builder: (context, state) => const OnBoardingScreen(),
      ),
      GoRoute(
        name: RouteName.home,
        path: RouteName.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        name: RouteName.history,
        path: RouteName.history,
        pageBuilder: (context, state) => _customTransitionPage(
          child: const HistoryPage(),
          direction: Direction.right,
        ),
      ),
      GoRoute(
        name: RouteName.result,
        path: RouteName.result,
        pageBuilder: (context, state) => _customTransitionPage(
          child: const ResultScreen(),
          direction: Direction.right,
        ),
      ),
      GoRoute(
        name: RouteName.settings,
        path: RouteName.settings,
        pageBuilder: (context, state) => _customTransitionPage(
          child:  SettingsScreen(),
          direction: Direction.right,
        ),
      ),
      GoRoute(
        name: RouteName.summarizedResult,
        path: RouteName.summarizedResult,
        pageBuilder: (context, state) => _customTransitionPage(
          child: SummarizedResultScreen(summarizedText: state.extra as String),
          direction: Direction.right,
        ),
      ),
      GoRoute(
        name: RouteName.convertedResult,
        path: RouteName.convertedResult,
        pageBuilder: (context, state) => _customTransitionPage(
          child: ConvertedResultScreen(convertedText: state.extra as String),
          direction: Direction.right,
        ),
      ),
    ],
  );  
