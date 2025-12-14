/// This file demonstrates how to use all the API services in the app.
/// Import this file to see usage examples for each service.

import 'package:grown_health/services/profile_service.dart';
import 'package:grown_health/services/water_service.dart';
import 'package:grown_health/services/meditation_service.dart';
import 'package:grown_health/services/exercise_service.dart';
import 'package:grown_health/services/upload_service.dart';
import 'package:grown_health/services/admin_service.dart';
import 'package:grown_health/models/profile_model.dart';
import 'package:grown_health/models/water_intake_model.dart';
import 'dart:io';

/// Example usage of ProfileService
class ProfileServiceExample {
  final String userToken;
  late final ProfileService _profileService;

  ProfileServiceExample(this.userToken) {
    _profileService = ProfileService(userToken);
  }

  /// Get user profile
  Future<void> getUserProfile() async {
    try {
      final profile = await _profileService.getProfile();
      print('Profile: ${profile.name}, Age: ${profile.age}');
    } catch (e) {
      print('Error getting profile: $e');
    }
  }

  /// Complete profile after registration
  Future<void> completeUserProfile() async {
    try {
      final profile = await _profileService.completeProfile(
        name: 'John Doe',
        age: 25,
        gender: 'male',
        weight: 70.5,
        height: 175.0,
      );
      print('Profile completed: ${profile.name}');
    } catch (e) {
      print('Error completing profile: $e');
    }
  }

  /// Update profile
  Future<void> updateUserProfile() async {
    try {
      final profile = await _profileService.updateProfile(
        name: 'John Updated',
        weight: 72.0,
      );
      print('Profile updated: ${profile.name}');
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  /// Update profile image
  Future<void> updateUserProfileImage(String imageUrl) async {
    try {
      final profile = await _profileService.updateProfileImage(imageUrl);
      print('Profile image updated: ${profile.profileImage}');
    } catch (e) {
      print('Error updating profile image: $e');
    }
  }

  /// Check profile status
  Future<void> checkProfileStatus() async {
    try {
      final status = await _profileService.getProfileStatus();
      print('Profile complete: ${status['isProfileComplete']}');
    } catch (e) {
      print('Error checking profile status: $e');
    }
  }
}

/// Example usage of WaterService
class WaterServiceExample {
  final String userToken;
  late final WaterService _waterService;

  WaterServiceExample(this.userToken) {
    _waterService = WaterService(userToken);
  }

  /// Get water goal
  Future<void> getWaterGoal() async {
    try {
      final goal = await _waterService.getWaterGoal();
      print('Water goal: $goal glasses');
    } catch (e) {
      print('Error getting water goal: $e');
    }
  }

  /// Set water goal
  Future<void> setWaterGoal(int goal) async {
    try {
      final result = await _waterService.setWaterGoal(goal);
      print('Water goal set: $result');
    } catch (e) {
      print('Error setting water goal: $e');
    }
  }

  /// Get today's water intake
  Future<void> getTodayWater() async {
    try {
      final today = await _waterService.getTodayWaterIntake();
      print('Today: ${today.count}/${today.goal} glasses (${today.percentage}%)');
      print('Remaining: ${today.remaining} glasses');
      print('Completed: ${today.isCompleted}');
    } catch (e) {
      print('Error getting today\'s water: $e');
    }
  }

  /// Add a glass of water
  Future<void> drinkWater() async {
    try {
      final result = await _waterService.addWaterGlass();
      print('Added water! Count: ${result.count}');
    } catch (e) {
      print('Error adding water: $e');
    }
  }

  /// Remove a glass of water
  Future<void> undoDrinkWater() async {
    try {
      final result = await _waterService.removeWaterGlass();
      print('Removed water! Count: ${result.count}');
    } catch (e) {
      print('Error removing water: $e');
    }
  }

  /// Set today's water count manually
  Future<void> setTodayWater(int count) async {
    try {
      final result = await _waterService.setTodayWaterCount(count);
      print('Water count set to: ${result.count}');
    } catch (e) {
      print('Error setting water count: $e');
    }
  }

  /// Get water history
  Future<void> getWaterHistory() async {
    try {
      // Get last 30 days
      final history = await _waterService.getWaterHistory(days: 30);
      print('Total days: ${history.totalDays}');
      print('Average intake: ${history.averageIntake} glasses');
      print('Total glasses: ${history.totalGlasses}');
      
      for (var intake in history.data) {
        print('${intake.date}: ${intake.count}/${intake.goal}');
      }
    } catch (e) {
      print('Error getting water history: $e');
    }
  }

  /// Get water intake for specific date
  Future<void> getWaterByDate(String date) async {
    try {
      final intake = await _waterService.getWaterIntakeByDate(date);
      print('$date: ${intake.count}/${intake.goal} glasses');
    } catch (e) {
      print('Error getting water by date: $e');
    }
  }
}

/// Example usage of MeditationService
class MeditationServiceExample {
  final String? userToken;
  late final MeditationService _meditationService;

  MeditationServiceExample(this.userToken) {
    _meditationService = MeditationService(userToken);
  }

  /// Get meditations with filters
  Future<void> getMeditations() async {
    try {
      final result = await _meditationService.getMeditations(
        page: 1,
        limit: 10,
        searchQuery: 'relaxation',
        categoryId: 'some-category-id',
      );
      
      print('Total meditations: ${result.total}');
      print('Page ${result.page} of ${result.totalPages}');
      
      for (var meditation in result.meditations) {
        print('${meditation.title} - ${meditation.duration}min');
      }
    } catch (e) {
      print('Error getting meditations: $e');
    }
  }

  /// Get single meditation
  Future<void> getMeditationById(String id) async {
    try {
      final meditation = await _meditationService.getMeditationById(id);
      print('Meditation: ${meditation.title}');
      print('Description: ${meditation.description}');
      print('Duration: ${meditation.duration}min');
    } catch (e) {
      print('Error getting meditation: $e');
    }
  }
}

/// Example usage of ExerciseService
class ExerciseServiceExample {
  final String? userToken;
  late final ExerciseService _exerciseService;

  ExerciseServiceExample(this.userToken) {
    _exerciseService = ExerciseService(userToken);
  }

  /// Get exercises with filters
  Future<void> getExercises() async {
    try {
      final result = await _exerciseService.getExercises(
        page: 1,
        limit: 10,
        searchQuery: 'push up',
        difficulty: 'beginner',
      );
      
      print('Total exercises: ${result.total}');
      print('Page ${result.page} of ${result.totalPages}');
      
      for (var exercise in result.exercises) {
        print('${exercise.title} - ${exercise.difficulty}');
        print('Equipment: ${exercise.equipmentList.join(", ")}');
      }
    } catch (e) {
      print('Error getting exercises: $e');
    }
  }

  /// Get single exercise
  Future<void> getExerciseById(String id) async {
    try {
      final exercise = await _exerciseService.getExerciseById(id);
      print('Exercise: ${exercise.title}');
      print('Description: ${exercise.description}');
      print('Duration: ${exercise.duration}min');
      print('Difficulty: ${exercise.difficulty}');
    } catch (e) {
      print('Error getting exercise: $e');
    }
  }
}

/// Example usage of UploadService
class UploadServiceExample {
  final String userToken;
  late final UploadService _uploadService;

  UploadServiceExample(this.userToken) {
    _uploadService = UploadService(userToken);
  }

  /// Upload image from file
  Future<void> uploadImageFile(File imageFile) async {
    try {
      final imageUrl = await _uploadService.uploadImage(imageFile);
      print('Image uploaded: $imageUrl');
      
      // Now you can use this URL to update profile image
      final profileService = ProfileService(userToken);
      await profileService.updateProfileImage(imageUrl);
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  /// Upload image from bytes (for web)
  Future<void> uploadImageBytes(List<int> bytes, String filename) async {
    try {
      final imageUrl = await _uploadService.uploadImageFromBytes(bytes, filename);
      print('Image uploaded: $imageUrl');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
}

/// Example usage of AdminService
class AdminServiceExample {
  final String adminToken;
  late final AdminService _adminService;

  AdminServiceExample(this.adminToken) {
    _adminService = AdminService(adminToken);
  }

  /// Get admin summary
  Future<void> getAdminSummary() async {
    try {
      final summary = await _adminService.getSummary();
      print('Users: ${summary.users}');
      print('Categories: ${summary.categories}');
      print('Exercises: ${summary.exercises}');
      print('Workouts: ${summary.workouts}');
      print('Meditations: ${summary.meditations}');
      print('Nutrition: ${summary.nutrition}');
      print('Medicines: ${summary.medicines}');
      print('FAQs: ${summary.faqs}');
    } catch (e) {
      print('Error getting admin summary: $e');
    }
  }
}

/// Complete workflow example: User registration to profile completion
class CompleteWorkflowExample {
  Future<void> userOnboardingFlow(String email, String password) async {
    try {
      // 1. Register/Login (using existing AuthService)
      // final authService = AuthService();
      // final token = await authService.register(email: email, password: password);
      
      // For this example, assume we have a token
      final token = 'your-jwt-token';
      
      // 2. Check if profile is complete
      final profileService = ProfileService(token);
      final status = await profileService.getProfileStatus();
      
      if (status['isProfileComplete'] == false) {
        // 3. Complete profile
        final profile = await profileService.completeProfile(
          name: 'John Doe',
          age: 25,
          gender: 'male',
          weight: 70.5,
          height: 175.0,
        );
        print('Profile completed for: ${profile.name}');
      }
      
      // 4. Set water goal
      final waterService = WaterService(token);
      await waterService.setWaterGoal(8); // 8 glasses per day
      
      // 5. Get today's water intake
      final today = await waterService.getTodayWaterIntake();
      print('Water goal: ${today.goal} glasses');
      
      // 6. Drink water
      await waterService.addWaterGlass();
      print('Added first glass of water!');
      
    } catch (e) {
      print('Error in onboarding flow: $e');
    }
  }
}
