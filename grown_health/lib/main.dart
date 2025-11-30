import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'workouts_screen.dart';
import 'main_shell.dart';
import 'challenge_detail_screen.dart';
import 'workout_player_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'workout_detail_screen.dart';
import 'onboarding_screen.dart';
import 'profile_setup_screen.dart';
import 'profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const MainShell(),
        '/workouts': (context) => const WorkoutsScreen(),
        '/challenge': (context) => const ChallengeDetailScreen(),
        '/player': (context) => const WorkoutPlayerScreen(),
        '/workout_detail': (context) => const WorkoutDetailScreen(),
        '/profile_setup': (context) => const ProfileSetupScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
