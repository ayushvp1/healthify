# How to Test the APIs in Real-Time

## 🚀 Quick Start Guide

### Step 1: Navigate to the API Test Screen

You have two options to access the test screen:

#### Option A: Add a button in your app
Add this button anywhere in your app (e.g., in the profile screen or settings):

```dart
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, '/api_test');
  },
  child: Text('Test APIs'),
)
```

#### Option B: Navigate programmatically
In your app's code, navigate to the test screen:

```dart
Navigator.pushNamed(context, '/api_test');
```

#### Option C: Modify initial route temporarily
In `lib/main.dart`, temporarily change the initial route:

```dart
return MaterialApp(
  debugShowCheckedModeBanner: false,
  initialRoute: '/api_test',  // Change this temporarily
  routes: {
    // ... routes
  },
);
```

---

## 📱 Using the API Test Screen

Once you're on the test screen, you'll see:

### 1. **Token Status Bar** (Top)
- **Green**: You're logged in and have a valid token ✅
- **Red**: No token found - you need to login first ❌

### 2. **Test Buttons**
- **Test All**: Runs all API tests sequentially
- **Profile**: Tests profile endpoints
- **Water**: Tests water tracking endpoints
- **Meditation**: Tests meditation endpoints
- **Exercise**: Tests exercise endpoints
- **Admin**: Tests admin endpoints (requires admin role)

### 3. **Output Console** (Bottom)
- Shows real-time results of API calls
- Green text on dark background
- Scrollable and selectable text
- Shows success (✅), warnings (⚠️), and errors (❌)

---

## 🧪 What Each Test Does

### Profile Service Test
```
✅ Get profile status
✅ Get full profile (if complete)
```

### Water Service Test
```
✅ Get water goal
✅ Set water goal to 8 glasses
✅ Get today's water intake
✅ Add one glass of water
```

### Meditation Service Test
```
✅ Get list of meditations (first 5)
✅ Shows total count and pagination info
```

### Exercise Service Test
```
✅ Get list of exercises (first 5)
✅ Shows total count and pagination info
```

### Admin Service Test
```
✅ Get admin summary statistics
✅ Shows counts for all entities
```

---

## 🔐 Prerequisites

### You MUST be logged in first!

If you see "No token - Please login first":

1. **Navigate to login screen**
2. **Login with your credentials**
3. **Return to the API test screen**

The test screen will automatically detect your token from the auth provider.

---

## 📝 Example Test Flow

1. **Start the app** (flutter run is already running)
2. **Login** to your account
3. **Navigate to `/api_test`** route
4. **Click "Test All"** to run all tests
5. **Watch the console** for results

### Expected Output Example:
```
🚀 Testing All Services...

🧪 Testing Profile Service...
📍 Testing: Get Profile Status
✅ Status: {isProfileComplete: true}

📍 Testing: Get Profile
✅ Profile: John Doe, Age: 25

🧪 Testing Water Service...
📍 Testing: Get Water Goal
✅ Water Goal: 8 glasses

📍 Testing: Get Today's Water Intake
✅ Today: 3/8 glasses
   Progress: 37.5%
   Remaining: 5 glasses
   Completed: false

📍 Testing: Add Water Glass
✅ Added! New count: 4

🧪 Testing Meditation Service...
📍 Testing: Get Meditations (page 1, limit 5)
✅ Total meditations: 25
   Page: 1/5
   Found 5 items:
   - Morning Meditation
   - Stress Relief
   - Sleep Better
   - Focus & Concentration
   - Mindful Breathing

✅ All tests completed!
```

---

## 🐛 Troubleshooting

### Problem: "No token - Please login first"
**Solution**: Login to your account first, then return to the test screen.

### Problem: "Network error: Unable to connect to server"
**Solution**: 
- Check your internet connection
- Verify the API URL in `lib/api_config.dart`
- Make sure the API server is running

### Problem: "401 Unauthorized"
**Solution**: 
- Your token may have expired
- Logout and login again
- Check if your account is active

### Problem: "Profile not complete"
**Solution**: 
- Complete your profile first
- Use the profile completion screen
- Required fields: name, age, gender, weight

### Problem: "Admin endpoints fail"
**Solution**: 
- Admin endpoints require admin role
- Regular users will get permission errors
- This is expected behavior

---

## 🎯 Testing Specific Features

### Test Profile Completion
1. Click "Profile" button
2. Check if profile is complete
3. If not, use the app to complete it
4. Test again

### Test Water Tracking
1. Click "Water" button
2. It will set goal to 8 glasses
3. It will add one glass
4. Check the output for current count

### Test Content Browsing
1. Click "Meditation" or "Exercise"
2. Check if content is loaded
3. Verify pagination works
4. Check total counts

---

## 💡 Tips

1. **Clear Log**: Click the clear icon (top right) to clear the console
2. **Scroll Output**: The console is scrollable - scroll down to see all results
3. **Copy Text**: The output is selectable - you can copy error messages
4. **Test Individually**: Test one service at a time for easier debugging
5. **Check Token**: Always verify the green token status bar before testing

---

## 🔄 Hot Reload

The app supports hot reload! If you make changes to the API services:

1. Save your changes
2. Hot reload (press `r` in terminal or save in VS Code)
3. Re-run the tests

---

## 📊 Understanding Results

### Success (✅)
- API call succeeded
- Data was returned correctly
- Everything is working

### Warning (⚠️)
- API call succeeded but with caveats
- Example: Profile not complete yet
- Not an error, just informational

### Error (❌)
- API call failed
- Shows error message
- Check the message for details

---

## 🚦 Next Steps After Testing

Once you've verified the APIs work:

1. **Integrate into your app**
   - Use the services in your screens
   - Follow the `INTEGRATION_CHECKLIST.md`

2. **Build UI screens**
   - Profile management screen
   - Water tracking widget
   - Meditation/Exercise browsers

3. **Add state management**
   - Create providers for each service
   - Manage loading and error states

4. **Handle errors gracefully**
   - Show user-friendly error messages
   - Add retry functionality

---

## 📞 Need Help?

- Check `API_IMPLEMENTATION_GUIDE.md` for detailed API docs
- Review `API_QUICK_REFERENCE.md` for code snippets
- See `lib/examples/api_usage_examples.dart` for usage examples
- Check `ARCHITECTURE.md` for architecture details

---

**Happy Testing! 🎉**

The API test screen is your playground to verify everything works before integrating into your app.
