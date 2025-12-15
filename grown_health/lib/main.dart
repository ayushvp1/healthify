import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/providers.dart';
import 'screens/screens.dart';
import 'screens/medicine/medicine_reminders_screen.dart';
import 'screens/medicine/add_medicine_screen.dart';
import 'screens/api_test_screen.dart';
import 'screens/profile_complete_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
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
        '/workout_plan': (context) => const WorkoutPlanScreen(),
        '/profile_setup': (context) => const ProfileSetupScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/profile-complete': (context) => const ProfileCompleteScreen(),
        '/medicine_reminders': (context) => const MedicineRemindersScreen(),
        '/add_medicine': (context) => const AddMedicineScreen(),
        '/api_test': (context) => const ApiTestScreen(),
      },
    );
  }
}
