import 'package:flutter/material.dart';

class AppConstants {
  // Job Categories
  static const List<String> jobCategories = [
    'Nanny',
    'House Cleaner',
    'Carpenter',
    'Mason',
    'Electrician',
    'Plumber',
    'Painter',
    'Gardener',
    'Security Guard',
    'Cook',
    'Driver',
    'Mechanic',
  ];

  // Sri Lankan Provinces
  static const List<String> provinces = [
    'Western Province',
    'Central Province',
    'Southern Province',
    'Uva Province',
    'Sabaragamuwa Province',
    'North Western Province',
    'North Central Province',
    'Northern Province',
    'Eastern Province',
  ];

  // Districts by Province
  static const Map<String, List<String>> districtsByProvince = {
    'Western Province': ['Colombo', 'Gampaha', 'Kalutara'],
    'Central Province': ['Kandy', 'Matale', 'Nuwara Eliya'],
    'Southern Province': ['Galle', 'Matara', 'Hambantota'],
    'Uva Province': ['Badulla', 'Monaragala'],
    'Sabaragamuwa Province': ['Ratnapura', 'Kegalle'],
    'North Western Province': ['Kurunegala', 'Puttalam'],
    'North Central Province': ['Anuradhapura', 'Polonnaruwa'],
    'Northern Province': [
      'Jaffna',
      'Kilinochchi',
      'Mannar',
      'Vavuniya',
      'Mullaitivu'
    ],
    'Eastern Province': ['Trincomalee', 'Batticaloa', 'Ampara'],
  };

  // Experience Levels
  static const List<String> experienceLevels = [
    'Beginner (0-1 years)',
    'Intermediate (1-3 years)',
    'Experienced (3-5 years)',
    'Expert (5+ years)',
  ];

  // Job Types
  static const List<String> jobTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Temporary',
    'Freelance',
  ];
}

class AppColors {
  static const primaryColor = Color(0xFF2196F3);
  static const primaryDark = Color(0xFF1976D2);
  static const accent = Color(0xFF03DAC6);
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const error = Color(0xFFB00020);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF000000);
  static const onBackground = Color(0xFF000000);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const divider = Color(0xFFBDBDBD);
}

class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 16.0;

  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
}
