# Healthify API Implementation Guide

This document provides a comprehensive guide to all the API implementations in the Healthify Flutter app.

## 📁 Project Structure

```
lib/
├── models/
│   ├── user_model.dart           # User authentication & profile data
│   ├── profile_model.dart        # User profile details
│   ├── water_intake_model.dart   # Water tracking models
│   ├── meditation_model.dart     # Meditation content models
│   └── exercise_model.dart       # Exercise content models
├── services/
│   ├── auth_service.dart         # Authentication (login/register)
│   ├── profile_service.dart      # Profile management
│   ├── water_service.dart        # Water tracking
│   ├── meditation_service.dart   # Meditation content
│   ├── exercise_service.dart     # Exercise content
│   ├── upload_service.dart       # Image uploads to Cloudinary
│   └── admin_service.dart        # Admin dashboard
└── examples/
    └── api_usage_examples.dart   # Usage examples for all services
```

## 🔐 Authentication

All API requests (except public endpoints) require a JWT token in the Authorization header:

```dart
'Authorization': 'Bearer <your-jwt-token>'
```

## 📚 API Services

### 1. ProfileService

Manages user profile data including personal information and profile completion.

#### Methods:

**Get Profile**
```dart
final profileService = ProfileService(userToken);
final profile = await profileService.getProfile();
```

**Complete Profile** (Required after registration)
```dart
final profile = await profileService.completeProfile(
  name: 'John Doe',
  age: 25,
  gender: 'male',      // 'male' | 'female' | 'other'
  weight: 70.5,        // in kg
  height: 175.0,       // in cm (optional)
);
```

**Update Profile** (Partial updates supported)
```dart
final profile = await profileService.updateProfile(
  name: 'John Updated',
  weight: 72.0,
  // Only include fields you want to update
);
```

**Update Profile Image**
```dart
final profile = await profileService.updateProfileImage(imageUrl);
```

**Check Profile Status**
```dart
final status = await profileService.getProfileStatus();
// Returns: { 'isProfileComplete': true/false }
```

---

### 2. WaterService

Tracks daily water intake with goal setting and historical data.

#### Methods:

**Get Water Goal**
```dart
final waterService = WaterService(userToken);
final goal = await waterService.getWaterGoal();
// Returns: number of glasses (int)
```

**Set Water Goal**
```dart
await waterService.setWaterGoal(8); // 8 glasses per day
```

**Get Today's Water Intake**
```dart
final today = await waterService.getTodayWaterIntake();
// Returns: WaterTodayResponse with:
// - count: current glasses drunk
// - goal: daily goal
// - percentage: completion percentage
// - remaining: glasses remaining
// - isCompleted: whether goal is met
```

**Add Water Glass** (+1)
```dart
final result = await waterService.addWaterGlass();
```

**Remove Water Glass** (-1)
```dart
final result = await waterService.removeWaterGlass();
```

**Set Today's Water Count** (Manual adjustment)
```dart
await waterService.setTodayWaterCount(5);
```

**Get Water History**
```dart
// Last 30 days
final history = await waterService.getWaterHistory(days: 30);

// Custom date range
final history = await waterService.getWaterHistory(
  startDate: '2024-01-01',
  endDate: '2024-01-31',
);

// Returns: WaterHistoryResponse with:
// - data: List<WaterIntakeModel>
// - totalDays: number of days
// - averageIntake: average glasses per day
// - totalGlasses: total glasses in period
```

**Get Water Intake by Date**
```dart
final intake = await waterService.getWaterIntakeByDate('2024-01-15');
```

---

### 3. MeditationService

Manages meditation content with search, filtering, and pagination.

#### Methods:

**Get Meditations** (with filters)
```dart
final meditationService = MeditationService(userToken);
final result = await meditationService.getMeditations(
  page: 1,
  limit: 10,
  searchQuery: 'relaxation',    // Optional: search in title
  categoryId: 'category-id',    // Optional: filter by category
);

// Returns: MeditationListResponse with:
// - meditations: List<MeditationModel>
// - total: total count
// - page: current page
// - limit: items per page
// - totalPages: total pages
```

**Get Single Meditation**
```dart
final meditation = await meditationService.getMeditationById('meditation-id');
```

**Create Meditation** (Admin only)
```dart
final meditation = await meditationService.createMeditation({
  'title': 'Morning Meditation',
  'description': 'Start your day with peace',
  'duration': 600,  // in seconds
  'category': 'category-id',
  'audioUrl': 'https://...',
  'imageUrl': 'https://...',
});
```

**Update Meditation** (Admin only)
```dart
final meditation = await meditationService.updateMeditation(
  'meditation-id',
  {'title': 'Updated Title'},
);
```

**Delete Meditation** (Admin only)
```dart
await meditationService.deleteMeditation('meditation-id');
```

---

### 4. ExerciseService

Manages exercise content with search, filtering by category and difficulty.

#### Methods:

**Get Exercises** (with filters)
```dart
final exerciseService = ExerciseService(userToken);
final result = await exerciseService.getExercises(
  page: 1,
  limit: 10,
  searchQuery: 'push up',           // Optional: search in title/description
  categoryId: 'category-id',        // Optional: filter by category
  difficulty: 'beginner',           // Optional: 'beginner' | 'intermediate' | 'advanced'
);

// Returns: ExerciseListResponse with:
// - exercises: List<ExerciseModel>
// - total: total count
// - page: current page
// - limit: items per page
// - totalPages: total pages
```

**Get Single Exercise**
```dart
final exercise = await exerciseService.getExerciseById('exercise-id');
```

**Create Exercise** (Admin only)
```dart
final exercise = await exerciseService.createExercise(
  title: 'Push Ups',
  category: 'category-id',
  description: 'Classic upper body exercise',
  difficulty: 'beginner',
  duration: 300,  // in seconds
  equipment: ['mat'],  // Can be String or List<String>
  image: 'https://...',
);
```

**Update Exercise** (Admin only)
```dart
final exercise = await exerciseService.updateExercise(
  'exercise-id',
  {'difficulty': 'intermediate'},
);
```

**Delete Exercise** (Admin only)
```dart
await exerciseService.deleteExercise('exercise-id');
```

---

### 5. UploadService

Handles image uploads to Cloudinary.

#### Methods:

**Upload Image from File** (Mobile)
```dart
final uploadService = UploadService(userToken);
final imageUrl = await uploadService.uploadImage(imageFile);

// Use the URL to update profile
final profileService = ProfileService(userToken);
await profileService.updateProfileImage(imageUrl);
```

**Upload Image from Bytes** (Web)
```dart
final imageUrl = await uploadService.uploadImageFromBytes(
  imageBytes,
  'profile_picture.jpg',
);
```

---

### 6. AdminService

Provides admin dashboard statistics.

#### Methods:

**Get Admin Summary**
```dart
final adminService = AdminService(adminToken);
final summary = await adminService.getSummary();

// Returns: AdminSummary with counts for:
// - users
// - categories
// - exercises
// - workouts
// - meditations
// - nutrition
// - medicines
// - faqs
```

---

## 🔄 Complete User Onboarding Flow

Here's a complete example of user registration to profile setup:

```dart
// 1. Register/Login
final authService = AuthService();
final token = await authService.register(
  email: 'user@example.com',
  password: 'password123',
);

// 2. Check profile status
final profileService = ProfileService(token);
final status = await profileService.getProfileStatus();

if (status['isProfileComplete'] == false) {
  // 3. Complete profile
  await profileService.completeProfile(
    name: 'John Doe',
    age: 25,
    gender: 'male',
    weight: 70.5,
    height: 175.0,
  );
}

// 4. Set water goal
final waterService = WaterService(token);
await waterService.setWaterGoal(8);

// 5. Start tracking water
await waterService.addWaterGlass();
```

---

## 🎨 Models Overview

### ProfileModel
```dart
{
  id: String?,
  email: String?,
  name: String?,
  age: int?,
  gender: String?,  // 'male' | 'female' | 'other'
  weight: double?,  // in kg
  height: double?,  // in cm
  profileImage: String?,
  isProfileComplete: bool?,
  createdAt: DateTime?,
  updatedAt: DateTime?,
}
```

### WaterIntakeModel
```dart
{
  id: String?,
  userId: String?,
  date: DateTime,
  count: int,
  goal: int,
  createdAt: DateTime?,
  updatedAt: DateTime?,
}

// Helper getters:
- percentage: double (0-100)
- remaining: int
- isCompleted: bool
```

### MeditationModel
```dart
{
  id: String?,
  title: String,
  description: String?,
  category: String?,
  duration: int?,  // in seconds
  audioUrl: String?,
  imageUrl: String?,
  instructor: String?,
  difficulty: String?,
  tags: List<String>?,
  createdAt: DateTime?,
  updatedAt: DateTime?,
}
```

### ExerciseModel
```dart
{
  id: String?,
  title: String,
  slug: String?,
  category: String?,
  description: String?,
  difficulty: String?,  // 'beginner' | 'intermediate' | 'advanced'
  duration: int?,  // in seconds
  equipment: dynamic,  // String or List<String>
  image: String?,
  videoUrl: String?,
  calories: int?,
  muscleGroups: List<String>?,
  createdAt: DateTime?,
  updatedAt: DateTime?,
}

// Helper getter:
- equipmentList: List<String>
```

---

## ⚠️ Error Handling

All services throw exceptions with descriptive messages. Always wrap API calls in try-catch:

```dart
try {
  final profile = await profileService.getProfile();
  // Handle success
} catch (e) {
  // Handle error
  print('Error: $e');
  // Show error message to user
}
```

Common error types:
- Network errors: "Network error: Unable to connect to server"
- Authentication errors: "Unauthorized" (401)
- Validation errors: "Invalid input" (400)
- Not found errors: "Resource not found" (404)

---

## 🔧 Configuration

Base URL is configured in `lib/api_config.dart`:

```dart
const String kBaseUrl = 'https://healthify-api.vercel.app/api';
```

---

## 📝 Notes

1. **Token Management**: Store the JWT token securely (use `flutter_secure_storage` or similar)
2. **Profile Completion**: Always check `isProfileComplete` after login to determine if user needs to complete profile
3. **Water Tracking**: The water goal is stored per user and persists across days
4. **Pagination**: Default pagination is 10 items per page, max recommended is 50
5. **Image Uploads**: Images are uploaded to Cloudinary and return a secure URL
6. **Admin Operations**: Create, update, and delete operations require admin role

---

## 🚀 Getting Started

1. Import the service you need:
```dart
import 'package:grown_health/services/profile_service.dart';
```

2. Initialize with user token:
```dart
final profileService = ProfileService(userToken);
```

3. Call the API method:
```dart
final profile = await profileService.getProfile();
```

4. Handle the response:
```dart
print('Welcome, ${profile.name}!');
```

---

## 📖 Additional Resources

- See `lib/examples/api_usage_examples.dart` for complete working examples
- Check individual service files for detailed method documentation
- Refer to model files for complete data structure definitions

---

**Last Updated**: December 2024
**API Version**: 1.0
**Base URL**: https://healthify-api.vercel.app/api
