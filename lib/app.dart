import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/design/tokens.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/scan/scan_screen.dart';
import 'features/results/results_screen.dart';
import 'features/history/history_screen.dart';
import 'features/guardian/guardian_screen.dart';
import 'features/auth/auth_screen.dart';
import 'features/account/account_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/privacy_screen.dart';
import 'core/security/scoring.dart';

class SafiApp extends StatelessWidget {
  const SafiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'صافي',
      debugShowCheckedModeBanner: false,
      theme: SafiTheme.dark(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const HomeScreen(),
        '/scan': (_) => const ScanScreen(),
        '/results': (_) => const ResultsScreen(),
        '/history': (_) => const HistoryScreen(),
        '/guardian': (_) => const GuardianScreen(),
        '/auth': (_) => const AuthScreen(),
        '/account': (_) => const AccountScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/privacy': (_) => const PrivacyScreen(),
      },
    );
  }
}

// Global state for demo
class AppState {
  static List<Finding> lastFindings = [];
  static int lastScore = 92;
  static DateTime? lastScanTime;
  static bool isLoggedIn = false;
  static String firstName = '';
  static String lastName = '';
}
