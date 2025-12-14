# Water Tracking Troubleshooting Guide

## 🔍 Current Issue

You're seeing: **"Unable to initialize water tracking"**

This error appears when the app is logged in but cannot connect to the water tracking API.

---

## 🐛 Possible Causes

### 1. **CORS Issue (Most Likely)**
- The API server at `https://healthify-api.vercel.app` may not have CORS enabled
- This prevents the Flutter app from making API requests
- **Solution**: Run on mobile/desktop instead of web, OR fix CORS on backend

### 2. **API Endpoint Not Available**
- The `/api/water` endpoints might not be deployed yet
- **Solution**: Verify the API is live and accessible

### 3. **Invalid Token**
- The JWT token might be expired or invalid
- **Solution**: Logout and login again

### 4. **Network Issue**
- No internet connection
- **Solution**: Check your internet connection

---

## ✅ Solutions

### **Solution 1: Test on Mobile (Recommended)**

CORS only affects web browsers. Testing on mobile will bypass this issue:

```bash
# Connect your Android device or start emulator
flutter run -d android

# Or for iOS (if on Mac)
flutter run -d ios
```

### **Solution 2: Fix CORS on Backend**

If you have access to the backend code, add CORS headers:

```javascript
// In your Express.js backend
const cors = require('cors');

app.use(cors({
  origin: '*', // Or specify your Flutter web URL
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

### **Solution 3: Verify API is Live**

Test the API manually:

```bash
# Get your token (from login)
curl -X POST https://healthify-api.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"your@email.com","password":"yourpassword"}'

# Test water endpoint
curl -X GET https://healthify-api.vercel.app/api/water/today \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### **Solution 4: Check Console Logs**

The app now has detailed logging. Check the Flutter console for:

```
🚰 Fetching today's water intake...
✅ Got water data: X/8 glasses
```

Or error messages:
```
❌ Failed to initialize water tracking: [error details]
```

---

## 🔧 Debugging Steps

### Step 1: Check if You're Logged In
- Look at the top of the home screen
- Should show your username (currently shows "test")
- ✅ You ARE logged in

### Step 2: Check Console Output
When the app loads, you should see:
```
🚰 Fetching today's water intake...
```

Then either:
- ✅ Success: `✅ Got water data: 0/8 glasses`
- ⚠️ No data: `⚠️ No water data found, initializing goal...`
- ❌ Error: `❌ Failed to initialize water tracking: [details]`

### Step 3: Verify API URL
Check `lib/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'https://healthify-api.vercel.app';
}
```

Make sure this URL is correct and accessible.

### Step 4: Test API Manually
Open your browser and try:
```
https://healthify-api.vercel.app/api/water/today
```

You should get a 401 error (expected without token) or a response.
If you get a CORS error or connection refused, the API has issues.

---

## 📱 Current Status

Based on your screenshot:
- ✅ App is running
- ✅ You're logged in as "test"
- ❌ Water tracking shows error
- ❌ Error: "Unable to initialize water tracking"

This suggests:
1. **Login is working** (you have a valid token)
2. **Water API is NOT working** (can't connect or CORS issue)

---

## 🎯 Recommended Next Steps

### **Option A: Test on Mobile (Fastest)**
```bash
# Stop current app
# Connect Android device
flutter run -d android
```
This will bypass CORS issues completely.

### **Option B: Check Backend**
1. Verify the water API endpoints are deployed
2. Check if CORS is enabled
3. Test endpoints with Postman/curl

### **Option C: Use Mock Data (Temporary)**
I can modify the water tracking card to use mock/local data for testing the UI, then connect to real API later.

---

## 🔍 What to Check in Console

When you run the app, look for these messages:

### **Success Flow:**
```
🚰 Fetching today's water intake...
✅ Got water data: 0/8 glasses
```

### **First Time User Flow:**
```
🚰 Fetching today's water intake...
⚠️ No water data found, initializing goal...
✅ Goal set to 8 glasses
✅ Got water data after setting goal: 0/8
```

### **Error Flow:**
```
🚰 Fetching today's water intake...
⚠️ No water data found, initializing goal...
❌ Failed to initialize water tracking: [error message]
```

The error message will tell us exactly what's wrong!

---

## 💡 Quick Test

To verify if it's a CORS issue:

1. Open browser DevTools (F12)
2. Go to Console tab
3. Look for errors like:
   - "CORS policy: No 'Access-Control-Allow-Origin' header"
   - "Failed to fetch"
   - "Network error"

If you see CORS errors, that's the issue!

---

## 📞 Need Help?

Share the console output (the debug messages) and I can help diagnose the exact issue!

The app now has detailed logging that will show exactly where it's failing:
- 🚰 = Starting API call
- ✅ = Success
- ⚠️ = Warning (expected, not an error)
- ❌ = Error (this is the problem)

---

**Let me know what you see in the console and we'll fix it together!** 🚀
