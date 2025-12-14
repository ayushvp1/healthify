# API Quick Reference

## 🔑 Authentication
```dart
import 'package:grown_health/services/auth_service.dart';

final authService = AuthService();
final token = await authService.login(email: email, password: password);
final token = await authService.register(email: email, password: password);
```

## 👤 Profile
```dart
import 'package:grown_health/services/profile_service.dart';

final service = ProfileService(token);

// Get profile
final profile = await service.getProfile();

// Complete profile (required after registration)
await service.completeProfile(
  name: 'John', age: 25, gender: 'male', weight: 70.5, height: 175.0
);

// Update profile
await service.updateProfile(name: 'John Updated', weight: 72.0);

// Update image
await service.updateProfileImage(imageUrl);

// Check status
final status = await service.getProfileStatus();
```

## 💧 Water Tracking
```dart
import 'package:grown_health/services/water_service.dart';

final service = WaterService(token);

// Goal
final goal = await service.getWaterGoal();
await service.setWaterGoal(8);

// Today's intake
final today = await service.getTodayWaterIntake();
// today.count, today.goal, today.percentage, today.remaining, today.isCompleted

// Add/Remove
await service.addWaterGlass();      // +1
await service.removeWaterGlass();   // -1
await service.setTodayWaterCount(5); // Set to 5

// History
final history = await service.getWaterHistory(days: 30);
final intake = await service.getWaterIntakeByDate('2024-01-15');
```

## 🧘 Meditations
```dart
import 'package:grown_health/services/meditation_service.dart';

final service = MeditationService(token);

// List (with filters)
final result = await service.getMeditations(
  page: 1, limit: 10, searchQuery: 'relax', categoryId: 'cat-id'
);

// Single
final meditation = await service.getMeditationById(id);

// Admin only
await service.createMeditation(data);
await service.updateMeditation(id, updates);
await service.deleteMeditation(id);
```

## 🏃 Exercises
```dart
import 'package:grown_health/services/exercise_service.dart';

final service = ExerciseService(token);

// List (with filters)
final result = await service.getExercises(
  page: 1, limit: 10, searchQuery: 'push', difficulty: 'beginner'
);

// Single
final exercise = await service.getExerciseById(id);

// Admin only
await service.createExercise(title: 'Push Ups', ...);
await service.updateExercise(id, updates);
await service.deleteExercise(id);
```

## 📤 Uploads
```dart
import 'package:grown_health/services/upload_service.dart';

final service = UploadService(token);

// From file (mobile)
final url = await service.uploadImage(imageFile);

// From bytes (web)
final url = await service.uploadImageFromBytes(bytes, 'filename.jpg');
```

## 👨‍💼 Admin
```dart
import 'package:grown_health/services/admin_service.dart';

final service = AdminService(adminToken);

final summary = await service.getSummary();
// summary.users, summary.categories, summary.exercises, etc.
```

## 🎯 Common Patterns

### Complete Onboarding Flow
```dart
// 1. Register
final token = await AuthService().register(email: email, password: password);

// 2. Check profile
final profileService = ProfileService(token);
final status = await profileService.getProfileStatus();

// 3. Complete if needed
if (!status['isProfileComplete']) {
  await profileService.completeProfile(
    name: name, age: age, gender: gender, weight: weight
  );
}

// 4. Set water goal
await WaterService(token).setWaterGoal(8);
```

### Upload & Update Profile Image
```dart
// 1. Upload image
final uploadService = UploadService(token);
final imageUrl = await uploadService.uploadImage(imageFile);

// 2. Update profile
final profileService = ProfileService(token);
await profileService.updateProfileImage(imageUrl);
```

### Water Tracking Widget
```dart
final waterService = WaterService(token);

// Get today's data
final today = await waterService.getTodayWaterIntake();

// Display: ${today.count} / ${today.goal} glasses
// Progress: ${today.percentage}%

// On tap to drink
await waterService.addWaterGlass();

// On undo
await waterService.removeWaterGlass();
```

## 📊 Model Properties

### ProfileModel
`id, email, name, age, gender, weight, height, profileImage, isProfileComplete`

### WaterIntakeModel
`id, userId, date, count, goal` + helpers: `percentage, remaining, isCompleted`

### MeditationModel
`id, title, description, category, duration, audioUrl, imageUrl, instructor, difficulty, tags`

### ExerciseModel
`id, title, slug, category, description, difficulty, duration, equipment, image, videoUrl, calories, muscleGroups` + helper: `equipmentList`

## ⚠️ Error Handling
```dart
try {
  final result = await service.someMethod();
} catch (e) {
  print('Error: $e');
  // Show error to user
}
```

## 🔧 Configuration
Base URL: `https://healthify-api.vercel.app/api` (in `lib/api_config.dart`)

## 📝 Notes
- All user endpoints require `Authorization: Bearer <token>`
- Admin endpoints require admin role
- Profile must be completed after registration
- Water goal persists across days
- Pagination default: 10 items/page
