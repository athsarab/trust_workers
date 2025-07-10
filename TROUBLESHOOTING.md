# Trust Workers App - Registration & Login Troubleshooting Guide

## IMMEDIATE ACTION NEEDED

### 🔧 Step 1: Enable Developer Mode (Required for Windows)
1. **Press `Win + I`** to open Settings
2. **Go to Update & Security > For developers**
3. **Select "Developer Mode"**
4. **Restart VS Code**
5. **Try running the app again:**
   ```bash
   cd d:\flutter_apps\trust_workers
   flutter run -d chrome
   ```

### 🧪 Step 2: Use the Built-in Debug Tool
I've added a Firebase debug tool to your login screen. When you run the app:

1. **Open the app in Chrome browser** (most reliable for debugging)
2. **Go to the Login screen**
3. **Scroll down to see the orange "Firebase Debug Tools" box**
4. **Click "Run Firebase Tests"**
5. **Watch the results in the black console box**

This will tell us exactly what's wrong with your Firebase setup.

## Current Issues Analysis

### Issue 1: Firestore User Data Not Saved
**Root Cause:** Most likely Firestore security rules are blocking writes OR there's a configuration problem.

### Issue 2: Login Type Cast Error  
**Root Cause:** When you try to login, the app tries to load user data from Firestore, but since the data wasn't saved during registration, it fails with a casting error.

## Expected Debug Test Results

✅ **If Firebase is working correctly**, you should see:
```
Test 1: Testing basic Firestore write...
✅ Test 1 PASSED: Basic write successful
Test 2: Testing basic Firestore read...
✅ Test 2 PASSED: Basic read successful
...
🎉 ALL TESTS COMPLETED SUCCESSFULLY!
```

❌ **If there's a problem**, you'll see specific error messages that will help us fix it.

### Step 2: Check Firebase Console Setup

1. **Go to [Firebase Console](https://console.firebase.google.com/)**
2. **Select your project: `trust-workers-app`**
3. **Check Authentication:**
   - Go to Authentication > Users
   - Verify if test users appear after registration attempts
4. **Check Firestore Database:**
   - Go to Firestore Database
   - Look for a `users` collection
   - Check if user documents exist

### Step 3: Update Firestore Security Rules

Current rules might be blocking writes. Update them:

1. **Go to Firestore Database > Rules**
2. **Replace existing rules with:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read and write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow authenticated users to read all users (for worker discovery)
    match /users/{userId} {
      allow read: if request.auth != null;
    }
    
    // Allow authenticated users to read and write job posts
    match /job_posts/{jobId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.uid == resource.data.postedBy || !exists(/databases/$(database)/documents/job_posts/$(jobId)));
    }
  }
}
```

3. **Click "Publish"**

### Step 4: Test Registration Step by Step

#### A. Enable Debug Logging

Add this to your `main.dart` (before runApp):

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable Firebase debug logging
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Add this line for debugging
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  runApp(const MyApp());
}
```

#### B. Test Registration in Browser Console

1. **Run the app in Chrome:**
   ```bash
   flutter run -d chrome
   ```

2. **Open Browser Developer Tools (F12)**
3. **Go to Console tab**
4. **Try registering a test user**
5. **Watch for debug messages**

#### C. Expected Debug Output

During registration, you should see:
```
AuthProvider: Firebase Auth user detected: [user-id]
Saving user data to Firestore: {name: John Doe, phone: +1234567890, ...}
Data saved successfully: {name: John Doe, phone: +1234567890, ...}
AuthProvider: Loading user data for UID: [user-id]
Document exists: true
Document data: {name: John Doe, phone: +1234567890, ...}
AuthProvider: User data loaded successfully: John Doe
```

### Step 5: Fix Common Issues

#### Issue 1: Internet Connectivity
```bash
# Test if Firebase can be reached
ping firebase.googleapis.com
```

#### Issue 2: Firebase Project Configuration
1. **Verify `android/app/google-services.json` exists and is valid**
2. **Verify the package name matches in:**
   - `android/app/build.gradle` (applicationId)
   - Firebase Console project settings
   - `google-services.json` file

#### Issue 3: Dependency Versions
Check if all Firebase dependencies are compatible:

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
```

### Step 6: Manual Testing Commands

#### Test Firebase Connection:
```bash
cd d:\flutter_apps\trust_workers
flutter clean
flutter pub get
flutter doctor -v
```

#### Test Firestore Directly:
Add this test button to your app (temporary):

```dart
ElevatedButton(
  onPressed: () async {
    try {
      final testDoc = FirebaseFirestore.instance.collection('test').doc('test');
      await testDoc.set({'message': 'Hello Firebase!', 'timestamp': DateTime.now()});
      print('✅ Firestore write successful');
      
      final snapshot = await testDoc.get();
      print('✅ Firestore read successful: ${snapshot.data()}');
    } catch (e) {
      print('❌ Firestore error: $e');
    }
  },
  child: Text('Test Firestore'),
)
```

## Known Working Test Data

### Test User 1 (Worker):
- **Email:** worker@example.com
- **Password:** password123
- **Name:** John Worker
- **Phone:** +1234567890
- **User Type:** Worker
- **Job Category:** Carpenter
- **Experience:** 5 years
- **Province:** Ontario

### Test User 2 (Normal):
- **Email:** user@example.com
- **Password:** password123
- **Name:** Jane User
- **Phone:** +0987654321
- **User Type:** Normal User

## Next Steps

1. **Enable Developer Mode** and run the app
2. **Check Firebase Console** for any error messages
3. **Update Firestore rules** as shown above
4. **Test registration** with debug output
5. **Report the specific error messages** you see in the console

## Getting More Help

If the issue persists, please provide:

1. **Exact error messages** from the console
2. **Screenshots** of Firebase Console (Authentication and Firestore sections)
3. **Debug output** from the app during registration/login
4. **Your Firestore security rules**

The app structure and code are correct - it's likely a configuration or permissions issue that can be resolved quickly once we identify the specific problem.
