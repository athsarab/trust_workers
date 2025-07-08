# Firebase Configuration

This document explains how to set up Firebase for the Trust Workers app.

## Prerequisites

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication with Email/Password
3. Enable Firestore Database
4. Configure Android and iOS apps in Firebase

## Setup Steps

### 1. Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: "trust-workers"
4. Enable Google Analytics (optional)
5. Click "Create project"

### 2. Enable Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password"
5. Click "Save"

### 3. Enable Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (you can configure security rules later)
4. Select a location closest to your users
5. Click "Done"

### 4. Add Android App

1. In Firebase Console, go to "Project settings" (gear icon)
2. Click "Add app" and select Android
3. Enter Android package name: `com.example.trust_workers`
4. Enter app nickname: "Trust Workers Android"
5. Leave SHA-1 empty for now (can be added later for release)
6. Click "Register app"
7. Download `google-services.json`
8. Copy the file to `android/app/` directory

### 5. Add iOS App

1. In Firebase Console, click "Add app" and select iOS
2. Enter iOS bundle ID: `com.example.trustWorkers`
3. Enter app nickname: "Trust Workers iOS"
4. Click "Register app"
5. Download `GoogleService-Info.plist`
6. Copy the file to `ios/Runner/` directory

### 6. Configure Android

Add to `android/build.gradle` (project level):
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

Add to `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation 'com.google.firebase:firebase-analytics'
}
```

### 7. Configure iOS

1. Open `ios/Runner.xcworkspace` in Xcode
2. Right-click on "Runner" in the Project Navigator
3. Select "Add Files to Runner"
4. Select the `GoogleService-Info.plist` file
5. Make sure "Copy items if needed" is checked
6. Click "Add"

## Firestore Database Structure

The app uses the following collections:

### users
```
{
  id: string (document ID),
  name: string,
  phone: string,
  email: string,
  userType: "UserType.normal" | "UserType.worker",
  jobCategory: string? (for workers),
  experience: string? (for workers),
  province: string? (for workers),
  createdAt: string (ISO date)
}
```

### job_posts
```
{
  id: string (document ID),
  title: string,
  jobType: string,
  category: string,
  district: string,
  description: string,
  contactPhone: string,
  postedBy: string (user ID),
  createdAt: string (ISO date),
  isActive: boolean
}
```

## Security Rules

For development, you can use these basic Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read job posts, only authenticated users can write
    match /job_posts/{document} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Running the App

After setting up Firebase:

1. Make sure you have placed the configuration files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

2. Run flutter commands:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Troubleshooting

### Common Issues

1. **Build errors**: Make sure configuration files are in the correct locations
2. **Authentication not working**: Check if Email/Password is enabled in Firebase Console
3. **Firestore errors**: Verify security rules allow your operations

### Debug Mode

The app includes error handling and will show toast messages for most Firebase-related errors.
