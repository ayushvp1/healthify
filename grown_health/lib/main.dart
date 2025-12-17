import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/core.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';
import 'screens/medicine/medicine_reminders_screen.dart';
import 'screens/medicine/add_medicine_screen.dart';
import 'screens/api_test_screen.dart';
import 'screens/profile_complete_screen.dart';
import 'screens/workout/bundle_detail_screen.dart';
import 'screens/workout/bundles_list_screen.dart';
import 'screens/workout/exercise_detail_screen.dart';
import 'screens/workout/exercise_timer_screen.dart';

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
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Handle dynamic routes with parameters
        final uri = Uri.parse(settings.name ?? '');

        // /bundle/:id - Bundle detail with dynamic ID
        if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'bundle') {
          final bundleId = uri.pathSegments[1];
          return MaterialPageRoute(
            builder: (context) => BundleDetailScreen(bundleId: bundleId),
            settings: settings,
          );
        }

        // Static routes
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignupScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const MainShell());
          case '/workouts':
            return MaterialPageRoute(builder: (_) => const WorkoutsScreen());
          case '/bundles':
            return MaterialPageRoute(builder: (_) => const BundlesListScreen());
          case '/challenge':
            return MaterialPageRoute(
              builder: (_) => const ChallengeDetailScreen(),
            );
          case '/player':
            return MaterialPageRoute(
              builder: (_) => const WorkoutPlayerScreen(),
            );
          case '/workout_detail':
            return MaterialPageRoute(
              builder: (_) => const WorkoutDetailScreen(),
            );
          case '/exercise_detail':
            return MaterialPageRoute(
              builder: (_) => const ExerciseDetailScreen(),
              settings: settings,
            );
          case '/exercise_timer':
            return MaterialPageRoute(
              builder: (_) => const ExerciseTimerScreen(),
              settings: settings,
            );
          case '/workout_plan':
            return MaterialPageRoute(builder: (_) => const WorkoutPlanScreen());
          case '/profile_setup':
            return MaterialPageRoute(
              builder: (_) => const ProfileSetupScreen(),
            );
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          case '/profile-complete':
            return MaterialPageRoute(
              builder: (_) => const ProfileCompleteScreen(),
            );
          case '/medicine_reminders':
            return MaterialPageRoute(
              builder: (_) => const MedicineRemindersScreen(),
            );
          case '/add_medicine':
            return MaterialPageRoute(
              builder: (_) => const AddMedicineScreen(),
              settings: settings,
            );
          case '/api_test':
            return MaterialPageRoute(builder: (_) => const ApiTestScreen());
          case '/nutrition':
            return MaterialPageRoute(builder: (_) => const NutritionScreen());
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
