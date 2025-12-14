# Integration Checklist

Use this checklist to integrate the API services into your Healthify app.

## ✅ Phase 1: Setup & Configuration

- [ ] **Verify API Base URL**
  - Check `lib/api_config.dart`
  - Ensure it points to: `https://healthify-api.vercel.app/api`
  - Test connectivity to the API

- [ ] **Install Dependencies**
  - Verify `http` package is in `pubspec.yaml`
  - Run `flutter pub get`

- [ ] **Review Documentation**
  - Read `API_IMPLEMENTATION_GUIDE.md`
  - Review `API_QUICK_REFERENCE.md`
  - Check `ARCHITECTURE.md`

## ✅ Phase 2: Authentication Integration

- [ ] **Update Auth Flow**
  - Ensure `AuthService` is being used for login/register
  - Store JWT token securely (use `flutter_secure_storage`)
  - Pass token to all services

- [ ] **Token Management**
  ```dart
  // Example: Store token
  final storage = FlutterSecureStorage();
  await storage.write(key: 'jwt_token', value: token);
  
  // Example: Retrieve token
  final token = await storage.read(key: 'jwt_token');
  ```

- [ ] **Auto-login**
  - Check for stored token on app start
  - Validate token with API
  - Navigate to appropriate screen

## ✅ Phase 3: Profile Integration

- [ ] **Profile Status Check**
  - After login, check if profile is complete
  - Use `ProfileService.getProfileStatus()`
  - Navigate to profile completion if needed

- [ ] **Profile Completion Screen**
  - Create UI for profile completion
  - Fields: name, age, gender, weight, height (optional)
  - Call `ProfileService.completeProfile()`
  - Handle validation errors

- [ ] **Profile Display**
  - Create profile view screen
  - Load profile with `ProfileService.getProfile()`
  - Display all profile fields
  - Add edit functionality

- [ ] **Profile Edit**
  - Create profile edit screen
  - Pre-fill with current values
  - Call `ProfileService.updateProfile()`
  - Support partial updates

- [ ] **Profile Image Upload**
  - Add image picker functionality
  - Upload with `UploadService.uploadImage()`
  - Update profile with `ProfileService.updateProfileImage()`
  - Show loading state during upload

## ✅ Phase 4: Water Tracking Integration

- [ ] **Water Goal Setup**
  - Create goal setting screen
  - Call `WaterService.setWaterGoal()`
  - Validate input (1-20 glasses)

- [ ] **Water Tracking Widget**
  - Create water intake widget for home screen
  - Load today's data with `WaterService.getTodayWaterIntake()`
  - Display: count/goal, percentage, remaining
  - Add drink button (+1)
  - Add undo button (-1)

- [ ] **Water Progress Visualization**
  - Create circular/linear progress indicator
  - Use `WaterTodayResponse.percentage`
  - Animate progress changes
  - Show completion state

- [ ] **Water History**
  - Create history/calendar view
  - Load with `WaterService.getWaterHistory()`
  - Display daily intake
  - Show statistics (average, total)
  - Add date picker for specific dates

- [ ] **Water Reminders** (Optional)
  - Set up local notifications
  - Remind user to drink water
  - Link to water tracking widget

## ✅ Phase 5: Meditation Integration

- [ ] **Meditation List Screen**
  - Create meditation browsing screen
  - Load with `MeditationService.getMeditations()`
  - Implement pagination
  - Add search functionality
  - Add category filter

- [ ] **Meditation Detail Screen**
  - Load single meditation with `getMeditationById()`
  - Display title, description, duration
  - Show instructor and difficulty
  - Add audio player (if audioUrl exists)
  - Display image

- [ ] **Meditation Player** (Optional)
  - Integrate audio player package
  - Play meditation audio
  - Show progress
  - Add play/pause controls

## ✅ Phase 6: Exercise Integration

- [ ] **Exercise List Screen**
  - Create exercise browsing screen
  - Load with `ExerciseService.getExercises()`
  - Implement pagination
  - Add search functionality
  - Add difficulty filter
  - Add category filter

- [ ] **Exercise Detail Screen**
  - Load single exercise with `getExerciseById()`
  - Display title, description, duration
  - Show difficulty and equipment
  - Display image/video
  - Show muscle groups

- [ ] **Exercise Video Player** (Optional)
  - Integrate video player package
  - Play exercise videos
  - Add controls

## ✅ Phase 7: Admin Features (If Applicable)

- [ ] **Admin Dashboard**
  - Create admin dashboard screen
  - Load with `AdminService.getSummary()`
  - Display all counts
  - Add refresh functionality

- [ ] **Content Management**
  - Create admin screens for:
    - Creating meditations
    - Editing meditations
    - Deleting meditations
    - Creating exercises
    - Editing exercises
    - Deleting exercises

## ✅ Phase 8: Error Handling & UX

- [ ] **Loading States**
  - Add loading indicators for all API calls
  - Use `CircularProgressIndicator` or custom loaders
  - Disable buttons during loading

- [ ] **Error Handling**
  - Wrap all API calls in try-catch
  - Show user-friendly error messages
  - Add retry functionality
  - Handle network errors gracefully

- [ ] **Offline Support** (Optional)
  - Cache profile data locally
  - Cache meditation/exercise lists
  - Sync when back online
  - Show offline indicator

- [ ] **Empty States**
  - Add empty state UI for:
    - No meditations found
    - No exercises found
    - No water history
  - Provide helpful messages

## ✅ Phase 9: State Management

Choose one and implement:

### Option A: Provider
- [ ] Create providers for:
  - `ProfileProvider`
  - `WaterProvider`
  - `MeditationProvider`
  - `ExerciseProvider`
- [ ] Inject services into providers
- [ ] Use `ChangeNotifier` for state updates
- [ ] Consume providers in widgets

### Option B: Riverpod
- [ ] Create providers for services
- [ ] Create state providers
- [ ] Use `FutureProvider` for async data
- [ ] Consume providers in widgets

### Option C: Bloc
- [ ] Create blocs for each feature
- [ ] Define events and states
- [ ] Inject services into blocs
- [ ] Use `BlocBuilder` in widgets

## ✅ Phase 10: Testing

- [ ] **Unit Tests**
  - Test model serialization
  - Test service methods (mock HTTP)
  - Test error handling

- [ ] **Widget Tests**
  - Test profile screens
  - Test water tracking widget
  - Test meditation/exercise lists

- [ ] **Integration Tests**
  - Test complete user flows
  - Test API integration
  - Test navigation

## ✅ Phase 11: Polish & Optimization

- [ ] **Performance**
  - Implement pagination properly
  - Cache frequently accessed data
  - Optimize image loading
  - Lazy load lists

- [ ] **Accessibility**
  - Add semantic labels
  - Test with screen readers
  - Ensure proper contrast
  - Add keyboard navigation

- [ ] **Analytics** (Optional)
  - Track API errors
  - Track user actions
  - Monitor performance

- [ ] **Logging**
  - Add debug logging for API calls
  - Log errors for debugging
  - Use proper log levels

## ✅ Phase 12: Deployment Preparation

- [ ] **Environment Configuration**
  - Set up dev/staging/prod environments
  - Configure API URLs per environment
  - Test against staging API

- [ ] **Security**
  - Ensure tokens are stored securely
  - Don't log sensitive data
  - Validate all user inputs
  - Handle API errors securely

- [ ] **Documentation**
  - Update README with setup instructions
  - Document any custom configurations
  - Add troubleshooting guide

## 📝 Code Snippets for Common Tasks

### Initialize Services with Token
```dart
class ServiceLocator {
  static String? _token;
  
  static void setToken(String token) {
    _token = token;
  }
  
  static ProfileService get profileService => ProfileService(_token);
  static WaterService get waterService => WaterService(_token);
  static MeditationService get meditationService => MeditationService(_token);
  static ExerciseService get exerciseService => ExerciseService(_token);
  static UploadService get uploadService => UploadService(_token);
  static AdminService get adminService => AdminService(_token);
}
```

### Provider Example
```dart
class ProfileProvider extends ChangeNotifier {
  final ProfileService _service;
  ProfileModel? _profile;
  bool _loading = false;
  String? _error;
  
  ProfileProvider(String token) : _service = ProfileService(token);
  
  ProfileModel? get profile => _profile;
  bool get loading => _loading;
  String? get error => _error;
  
  Future<void> loadProfile() async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      _profile = await _service.getProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
```

### Error Handling Widget
```dart
class ApiErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  
  const ApiErrorWidget({
    required this.error,
    required this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

## 🎯 Priority Order

**High Priority (Must Have):**
1. Authentication Integration
2. Profile Integration
3. Water Tracking Integration
4. Error Handling

**Medium Priority (Should Have):**
5. Meditation Integration
6. Exercise Integration
7. State Management
8. Loading States

**Low Priority (Nice to Have):**
9. Admin Features
10. Offline Support
11. Analytics
12. Advanced Features

## 📞 Support

If you encounter issues:
1. Check the API documentation
2. Review the example code in `lib/examples/api_usage_examples.dart`
3. Verify your API token is valid
4. Check network connectivity
5. Review error messages carefully

---

**Good luck with your integration! 🚀**

Mark items as complete as you go. This checklist will help ensure nothing is missed.
