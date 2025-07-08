# # Trust Workers - Job Marketplace App

Trust Workers is a Flutter mobile application that connects job seekers (like nannies, home workers, carpenters, and masons) with people who need their services.

## Features

### Two User Types

**Workers** - Skilled professionals looking for work
- Register with detailed profiles (name, phone, job category, experience, province)
- Browse available job posts
- Contact employers directly
- View jobs by category

**Normal Users** - People who need services
- Simple registration (name, phone, email)
- Create and manage job posts
- Browse workers by category
- Search for specific skills

### Core Functionality

- **Firebase Authentication** - Secure email/password authentication
- **Firestore Database** - Real-time data storage and synchronization
- **Job Categories** - 12+ categories including Nanny, Carpenter, Electrician, etc.
- **Location-based** - Filter by Sri Lankan provinces and districts
- **Modern UI** - Clean, user-friendly interface with Material Design
- **Real-time Updates** - Live job posts and worker listings

## Screenshots

*Add screenshots here when available*

## Getting Started

### Prerequisites

- Flutter SDK (3.6.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd trust_workers
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Follow the detailed instructions in `FIREBASE_SETUP.md`
   - Create a Firebase project
   - Enable Authentication and Firestore
   - Add configuration files for Android/iOS

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_model.dart       # User data structure
│   └── job_post.dart         # Job post data structure
├── services/                 # Business logic services
│   ├── auth_service.dart     # Authentication operations
│   └── database_service.dart # Firestore operations
├── providers/                # State management
│   ├── auth_provider.dart    # Authentication state
│   └── job_provider.dart     # Job and worker data state
├── screens/                  # App screens
│   ├── splash_screen.dart    # Loading screen
│   ├── auth/                 # Login & registration
│   ├── home/                 # Main navigation
│   ├── jobs/                 # Job-related screens
│   ├── workers/              # Worker-related screens
│   ├── profile/              # User profile
│   └── notifications/        # Notifications
├── widgets/                  # Reusable UI components
│   ├── custom_button.dart    # Styled buttons
│   ├── custom_text_field.dart# Form inputs
│   ├── job_card.dart         # Job display card
│   └── worker_card.dart      # Worker display card
└── utils/                    # Constants and utilities
    └── constants.dart        # App constants and theme
```

## Key Components

### Authentication System
- Email/password registration and login
- User type selection (Worker/Normal User)
- Password reset functionality
- Secure session management

### Job Management
- Create, read, update, delete job posts
- Filter jobs by category and location
- Real-time job listings
- Contact information sharing

### Worker Directory
- Browse workers by category
- View worker profiles with experience and location
- Direct contact options (call, email, copy phone)
- Search functionality

### Modern Navigation
- Bottom navigation bar adapted for user type
- Category sidebar for easy browsing
- Search functionality
- User-friendly interface

## Technology Stack

- **Framework**: Flutter 3.6.0+
- **Language**: Dart
- **Backend**: Firebase
  - Authentication
  - Firestore Database
- **State Management**: Provider
- **UI**: Material Design 3
- **Fonts**: Google Fonts (Inter)

## Configuration

### Job Categories
The app supports 12 job categories:
- Nanny
- House Cleaner
- Carpenter
- Mason
- Electrician
- Plumber
- Painter
- Gardener
- Security Guard
- Cook
- Driver
- Mechanic

### Location Support
- All 9 Sri Lankan provinces
- Districts organized by province
- Location-based filtering

## Development

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable names
- Document complex functions
- Keep widgets small and focused

### Adding New Features

1. **New Screen**: Add to appropriate folder in `screens/`
2. **New Widget**: Add to `widgets/` if reusable
3. **New Service**: Add to `services/` for business logic
4. **New Model**: Add to `models/` for data structures

### Testing
```bash
# Run tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## Deployment

### Android
1. Configure signing keys
2. Build release APK:
   ```bash
   flutter build apk --release
   ```

### iOS
1. Configure certificates in Xcode
2. Build for iOS:
   ```bash
   flutter build ios --release
   ```

## Customization Guide

### Theme Colors
Edit `lib/utils/constants.dart` to change app colors:
```dart
class AppColors {
  static const primaryColor = Color(0xFF2196F3);  // Change primary color
  static const primaryDark = Color(0xFF1976D2);   // Change dark variant
  // ... other colors
}
```

### Job Categories
Add/modify categories in `lib/utils/constants.dart`:
```dart
static const List<String> jobCategories = [
  'Your New Category',
  // ... existing categories
];
```

### Provinces/Districts
Update location data in `constants.dart` for different countries.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support or questions:
- Email: support@trustworkers.com
- Create an issue in this repository

## Roadmap

### Upcoming Features
- [ ] Push notifications
- [ ] In-app messaging
- [ ] Worker ratings and reviews
- [ ] Job application tracking
- [ ] Payment integration
- [ ] Multi-language support
- [ ] Advanced search filters
- [ ] Worker portfolio/gallery

### Known Issues
- Phone calling requires url_launcher package
- Email functionality needs mailto implementation
- Notification system is placeholder

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Material Design for UI guidelines
- Google Fonts for typography
