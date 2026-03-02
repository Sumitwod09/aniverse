import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables (safe to fail)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Note: .env file not found: $e');
  }
  
  // Check if user has seen onboarding
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  
  runApp(
    ProviderScope(
      child: AniVerseApp(
        showOnboarding: !hasSeenOnboarding,
      ),
    ),
  );
}

class AniVerseApp extends StatelessWidget {
  final bool showOnboarding;

  const AniVerseApp({
    super.key,
    required this.showOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniVerse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: showOnboarding 
          ? const WelcomeScreen()
          : const HomeScreen(),
    );
  }
}
