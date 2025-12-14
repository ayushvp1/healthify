# Healthify API Architecture

## 📐 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        Flutter App                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Screens    │  │   Widgets    │  │  Providers   │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                 │                 │              │
│         └─────────────────┴─────────────────┘              │
│                           │                                │
│  ┌────────────────────────▼────────────────────────────┐   │
│  │              Service Layer                          │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐           │   │
│  │  │ Profile  │ │  Water   │ │Meditation│  ...      │   │
│  │  │ Service  │ │ Service  │ │ Service  │           │   │
│  │  └──────────┘ └──────────┘ └──────────┘           │   │
│  └────────────────────────┬────────────────────────────┘   │
│                           │                                │
│  ┌────────────────────────▼────────────────────────────┐   │
│  │              Model Layer                            │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐           │   │
│  │  │ Profile  │ │  Water   │ │Meditation│  ...      │   │
│  │  │  Model   │ │  Model   │ │  Model   │           │   │
│  │  └──────────┘ └──────────┘ └──────────┘           │   │
│  └────────────────────────┬────────────────────────────┘   │
│                           │                                │
└───────────────────────────┼────────────────────────────────┘
                            │
                            │ HTTP/HTTPS
                            │
┌───────────────────────────▼────────────────────────────────┐
│                    API Server                              │
│           https://healthify-api.vercel.app/api             │
├────────────────────────────────────────────────────────────┤
│  /auth          - Authentication                           │
│  /profile       - User Profile                             │
│  /water         - Water Tracking                           │
│  /meditations   - Meditation Content                       │
│  /exercises     - Exercise Content                         │
│  /uploads       - Image Uploads (Cloudinary)               │
│  /admin         - Admin Dashboard                          │
└────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow

### Example: User Profile Update

```
┌──────────┐      ┌──────────────┐      ┌──────────┐      ┌──────────┐
│  Screen  │─────▶│ProfileService│─────▶│   HTTP   │─────▶│   API    │
│          │      │              │      │  Request │      │  Server  │
└──────────┘      └──────────────┘      └──────────┘      └──────────┘
     ▲                                                           │
     │                                                           │
     │            ┌──────────────┐      ┌──────────┐            │
     └────────────│ProfileModel  │◀─────│   HTTP   │◀───────────┘
                  │              │      │ Response │
                  └──────────────┘      └──────────┘
```

### Flow Steps:
1. **User Action**: User updates profile in UI
2. **Service Call**: Screen calls `ProfileService.updateProfile()`
3. **HTTP Request**: Service sends PUT request with JWT token
4. **API Processing**: Server validates, updates database
5. **HTTP Response**: Server returns updated profile JSON
6. **Model Creation**: Service creates `ProfileModel` from JSON
7. **UI Update**: Screen receives model and updates UI

## 🏗️ Service Architecture

### Each Service Follows This Pattern:

```dart
class SomeService {
  final String? _token;              // JWT token for auth
  
  SomeService(this._token);          // Constructor
  
  Map<String, String> get _headers { // Auth headers
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
  
  Future<Model> someMethod() async { // API method
    final uri = Uri.parse('$kBaseUrl/endpoint');
    
    try {
      final res = await http.get(uri, headers: _headers);
      
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        return Model.fromJson(data);
      } else {
        throw Exception('Error message');
      }
    } catch (e) {
      // Error handling
      rethrow;
    }
  }
}
```

## 📦 Model Architecture

### Each Model Follows This Pattern:

```dart
class SomeModel {
  final String? id;
  final String requiredField;
  final int? optionalField;
  
  const SomeModel({
    this.id,
    required this.requiredField,
    this.optionalField,
  });
  
  // From JSON (API → App)
  factory SomeModel.fromJson(Map<String, dynamic> json) {
    return SomeModel(
      id: json['_id'] as String?,
      requiredField: json['requiredField'] as String,
      optionalField: json['optionalField'] as int?,
    );
  }
  
  // To JSON (App → API)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'requiredField': requiredField,
      if (optionalField != null) 'optionalField': optionalField,
    };
  }
  
  // Immutable updates
  SomeModel copyWith({
    String? id,
    String? requiredField,
    int? optionalField,
  }) {
    return SomeModel(
      id: id ?? this.id,
      requiredField: requiredField ?? this.requiredField,
      optionalField: optionalField ?? this.optionalField,
    );
  }
}
```

## 🔐 Authentication Flow

```
┌──────────────┐
│ User enters  │
│ credentials  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ AuthService  │
│   .login()   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  API Server  │
│ /auth/login  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  JWT Token   │
│   returned   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Store token  │
│  securely    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Use token in │
│ all services │
└──────────────┘
```

## 💧 Water Tracking Flow

```
┌──────────────┐
│  App Start   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ WaterService │
│ .getGoal()   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ .getToday()  │
│ Display UI   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ User taps    │
│ drink button │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│.addWaterGlass│
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Update UI    │
│ with new     │
│ count        │
└──────────────┘
```

## 📱 Profile Completion Flow

```
┌──────────────┐
│   Register   │
│   /Login     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Get Profile  │
│   Status     │
└──────┬───────┘
       │
       ▼
┌──────────────┐     Yes     ┌──────────────┐
│  Complete?   │────────────▶│  Main App    │
└──────┬───────┘             └──────────────┘
       │ No
       ▼
┌──────────────┐
│   Show       │
│  Complete    │
│  Profile     │
│   Screen     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ User enters  │
│ name, age,   │
│ gender,      │
│ weight       │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│.completeProfile│
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Main App    │
└──────────────┘
```

## 🎯 Service Dependencies

```
┌─────────────────────────────────────────┐
│           All Services                  │
│  ┌─────────────────────────────────┐   │
│  │  Depend on:                     │   │
│  │  - api_config.dart (kBaseUrl)   │   │
│  │  - http package                 │   │
│  │  - dart:convert                 │   │
│  │  - Respective models            │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│           All Models                    │
│  ┌─────────────────────────────────┐   │
│  │  No external dependencies       │   │
│  │  Pure Dart classes              │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

## 📊 File Organization

```
lib/
├── api_config.dart              # Base URL configuration
├── models/                      # Data models
│   ├── user_model.dart         # User + Profile
│   ├── profile_model.dart      # Profile details
│   ├── water_intake_model.dart # Water tracking
│   ├── meditation_model.dart   # Meditation content
│   └── exercise_model.dart     # Exercise content
├── services/                    # API services
│   ├── auth_service.dart       # Authentication
│   ├── profile_service.dart    # Profile management
│   ├── water_service.dart      # Water tracking
│   ├── meditation_service.dart # Meditation content
│   ├── exercise_service.dart   # Exercise content
│   ├── upload_service.dart     # Image uploads
│   └── admin_service.dart      # Admin operations
└── examples/                    # Usage examples
    └── api_usage_examples.dart # Code examples
```

## 🔄 State Management Integration

### With Provider (Recommended):

```dart
class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService;
  ProfileModel? _profile;
  
  ProfileProvider(String token) 
    : _profileService = ProfileService(token);
  
  ProfileModel? get profile => _profile;
  
  Future<void> loadProfile() async {
    _profile = await _profileService.getProfile();
    notifyListeners();
  }
  
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    _profile = await _profileService.updateProfile(...);
    notifyListeners();
  }
}
```

### With Riverpod:

```dart
final profileServiceProvider = Provider<ProfileService>((ref) {
  final token = ref.watch(authTokenProvider);
  return ProfileService(token);
});

final profileProvider = FutureProvider<ProfileModel>((ref) async {
  final service = ref.watch(profileServiceProvider);
  return service.getProfile();
});
```

## 🎨 UI Integration Example

```dart
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileService _profileService;
  ProfileModel? _profile;
  bool _loading = true;
  
  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(userToken);
    _loadProfile();
  }
  
  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      // Show error
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_loading) return CircularProgressIndicator();
    if (_profile == null) return Text('Error loading profile');
    
    return Column(
      children: [
        Text('Name: ${_profile!.name}'),
        Text('Age: ${_profile!.age}'),
        // ... more UI
      ],
    );
  }
}
```

---

**This architecture provides:**
- ✅ Clear separation of concerns
- ✅ Type safety throughout
- ✅ Easy testing
- ✅ Scalable structure
- ✅ Maintainable code
- ✅ Reusable components
