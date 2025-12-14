import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/profile_service.dart';
import '../services/water_service.dart';
import '../services/meditation_service.dart';
import '../services/exercise_service.dart';
import '../services/admin_service.dart';
import '../models/profile_model.dart';
import '../models/water_intake_model.dart';
import '../providers/auth_provider.dart';

class ApiTestScreen extends ConsumerStatefulWidget {
  const ApiTestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends ConsumerState<ApiTestScreen> {
  String _output = 'Ready to test APIs...\n';
  bool _loading = false;

  void _log(String message) {
    setState(() {
      _output += '\n$message';
    });
    print(message);
  }

  void _clearLog() {
    setState(() {
      _output = 'Log cleared.\n';
    });
  }

  Future<void> _testProfileService() async {
    final userToken = ref.read(authProvider).user?.token;
    
    if (userToken == null) {
      _log('❌ Error: No token available. Please login first.');
      return;
    }

    setState(() => _loading = true);
    _log('\n🧪 Testing Profile Service...');

    try {
      final service = ProfileService(userToken);

      // Test 1: Get Profile Status
      _log('📍 Testing: Get Profile Status');
      final status = await service.getProfileStatus();
      _log('✅ Status: ${status.toString()}');

      // Test 2: Get Profile
      _log('\n📍 Testing: Get Profile');
      try {
        final profile = await service.getProfile();
        _log('✅ Profile: ${profile.name}, Age: ${profile.age}');
      } catch (e) {
        _log('⚠️ Profile not complete or error: $e');
      }
    } catch (e) {
      _log('❌ Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _testWaterService() async {
    final userToken = ref.read(authProvider).user?.token;
    
    if (userToken == null) {
      _log('❌ Error: No token available. Please login first.');
      return;
    }

    setState(() => _loading = true);
    _log('\n🧪 Testing Water Service...');

    try {
      final service = WaterService(userToken);

      // Test 1: Get Water Goal
      _log('📍 Testing: Get Water Goal');
      try {
        final goal = await service.getWaterGoal();
        _log('✅ Water Goal: $goal glasses');
      } catch (e) {
        _log('⚠️ No goal set yet: $e');
      }

      // Test 2: Set Water Goal
      _log('\n📍 Testing: Set Water Goal to 8');
      try {
        await service.setWaterGoal(8);
        _log('✅ Water goal set to 8 glasses');
      } catch (e) {
        _log('❌ Error setting goal: $e');
      }

      // Test 3: Get Today's Water Intake
      _log('\n📍 Testing: Get Today\'s Water Intake');
      try {
        final today = await service.getTodayWaterIntake();
        _log('✅ Today: ${today.count}/${today.goal} glasses');
        _log('   Progress: ${today.percentage.toStringAsFixed(1)}%');
        _log('   Remaining: ${today.remaining} glasses');
        _log('   Completed: ${today.isCompleted}');
      } catch (e) {
        _log('❌ Error: $e');
      }

      // Test 4: Add Water Glass
      _log('\n📍 Testing: Add Water Glass');
      try {
        final result = await service.addWaterGlass();
        _log('✅ Added! New count: ${result.count}');
      } catch (e) {
        _log('❌ Error: $e');
      }
    } catch (e) {
      _log('❌ Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _testMeditationService() async {
    final userToken = ref.read(authProvider).user?.token;
    
    setState(() => _loading = true);
    _log('\n🧪 Testing Meditation Service...');

    try {
      final service = MeditationService(userToken);

      // Test: Get Meditations
      _log('📍 Testing: Get Meditations (page 1, limit 5)');
      final result = await service.getMeditations(page: 1, limit: 5);
      _log('✅ Total meditations: ${result.total}');
      _log('   Page: ${result.page}/${result.totalPages}');
      _log('   Found ${result.meditations.length} items:');
      for (var meditation in result.meditations) {
        _log('   - ${meditation.title}');
      }
    } catch (e) {
      _log('❌ Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _testExerciseService() async {
    final userToken = ref.read(authProvider).user?.token;
    
    setState(() => _loading = true);
    _log('\n🧪 Testing Exercise Service...');

    try {
      final service = ExerciseService(userToken);

      // Test: Get Exercises
      _log('📍 Testing: Get Exercises (page 1, limit 5)');
      final result = await service.getExercises(page: 1, limit: 5);
      _log('✅ Total exercises: ${result.total}');
      _log('   Page: ${result.page}/${result.totalPages}');
      _log('   Found ${result.exercises.length} items:');
      for (var exercise in result.exercises) {
        _log('   - ${exercise.title} (${exercise.difficulty})');
      }
    } catch (e) {
      _log('❌ Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _testAdminService() async {
    final userToken = ref.read(authProvider).user?.token;
    
    if (userToken == null) {
      _log('❌ Error: No token available. Please login first.');
      return;
    }

    setState(() => _loading = true);
    _log('\n🧪 Testing Admin Service...');

    try {
      final service = AdminService(userToken);

      _log('📍 Testing: Get Admin Summary');
      final summary = await service.getSummary();
      _log('✅ Admin Summary:');
      _log('   Users: ${summary.users}');
      _log('   Categories: ${summary.categories}');
      _log('   Exercises: ${summary.exercises}');
      _log('   Workouts: ${summary.workouts}');
      _log('   Meditations: ${summary.meditations}');
      _log('   Nutrition: ${summary.nutrition}');
      _log('   Medicines: ${summary.medicines}');
      _log('   FAQs: ${summary.faqs}');
    } catch (e) {
      _log('❌ Error (may need admin role): $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _testAllServices() async {
    _clearLog();
    _log('🚀 Testing All Services...\n');
    await _testProfileService();
    await _testWaterService();
    await _testMeditationService();
    await _testExerciseService();
    await _testAdminService();
    _log('\n✅ All tests completed!');
  }

  @override
  Widget build(BuildContext context) {
    final userToken = ref.watch(authProvider).user?.token;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearLog,
            tooltip: 'Clear Log',
          ),
        ],
      ),
      body: Column(
        children: [
          // Token Status
          Container(
            padding: const EdgeInsets.all(16),
            color: userToken != null ? Colors.green[100] : Colors.red[100],
            child: Row(
              children: [
                Icon(
                  userToken != null ? Icons.check_circle : Icons.error,
                  color: userToken != null ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    userToken != null
                        ? 'Token: ${userToken.substring(0, 20)}...'
                        : 'No token - Please login first',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Test Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _loading ? null : _testAllServices,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Test All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _testProfileService,
                  child: const Text('Profile'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _testWaterService,
                  child: const Text('Water'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _testMeditationService,
                  child: const Text('Meditation'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _testExerciseService,
                  child: const Text('Exercise'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _testAdminService,
                  child: const Text('Admin'),
                ),
              ],
            ),
          ),

          // Loading Indicator
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),

          // Output Log
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _output,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
