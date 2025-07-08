import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserType _selectedUserType = UserType.normal;
  String? _selectedJobCategory;
  String? _selectedExperience;
  String? _selectedProvince;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // Validate worker-specific fields
      if (_selectedUserType == UserType.worker) {
        if (_selectedJobCategory == null ||
            _selectedExperience == null ||
            _selectedProvince == null) {
          Fluttertoast.showToast(
            msg: 'Please fill all worker details',
            backgroundColor: AppColors.error,
            textColor: AppColors.onPrimary,
          );
          return;
        }
      }

      final userModel = UserModel(
        id: '', // Will be set by Firebase
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        userType: _selectedUserType,
        jobCategory: _selectedJobCategory,
        experience: _selectedExperience,
        province: _selectedProvince,
        createdAt: DateTime.now(),
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userModel: userModel,
      );

      if (success && mounted) {
        Fluttertoast.showToast(
          msg: 'Account created successfully!',
          backgroundColor: Colors.green,
          textColor: AppColors.onPrimary,
        );
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (authProvider.errorMessage != null) {
        Fluttertoast.showToast(
          msg: authProvider.errorMessage!,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: AppColors.error,
          textColor: AppColors.onPrimary,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Type Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'I am a:',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<UserType>(
                                title: const Text('Regular User'),
                                subtitle: const Text('Find workers'),
                                value: UserType.normal,
                                groupValue: _selectedUserType,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUserType = value!;
                                    // Clear worker-specific fields
                                    _selectedJobCategory = null;
                                    _selectedExperience = null;
                                    _selectedProvince = null;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<UserType>(
                                title: const Text('Worker'),
                                subtitle: const Text('Find jobs'),
                                value: UserType.worker,
                                groupValue: _selectedUserType,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUserType = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.paddingLarge),

                // Basic Information
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),

                // Name Field
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  prefixIcon: Icons.person_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.paddingMedium),

                // Phone Field
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Phone Number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.paddingMedium),

                // Email Field
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.paddingMedium),

                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  prefixIcon: Icons.lock_outlined,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.paddingMedium),

                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  prefixIcon: Icons.lock_outlined,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                // Worker-specific fields
                if (_selectedUserType == UserType.worker) ...[
                  const SizedBox(height: AppSizes.paddingLarge),
                  Text(
                    'Worker Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),

                  // Job Category Dropdown
                  CustomDropdown<String>(
                    labelText: 'Job Category',
                    value: _selectedJobCategory,
                    items: AppConstants.jobCategories,
                    onChanged: (value) {
                      setState(() {
                        _selectedJobCategory = value;
                      });
                    },
                    prefixIcon: Icons.work_outlined,
                  ),

                  const SizedBox(height: AppSizes.paddingMedium),

                  // Experience Dropdown
                  CustomDropdown<String>(
                    labelText: 'Experience Level',
                    value: _selectedExperience,
                    items: AppConstants.experienceLevels,
                    onChanged: (value) {
                      setState(() {
                        _selectedExperience = value;
                      });
                    },
                    prefixIcon: Icons.star_outlined,
                  ),

                  const SizedBox(height: AppSizes.paddingMedium),

                  // Province Dropdown
                  CustomDropdown<String>(
                    labelText: 'Province',
                    value: _selectedProvince,
                    items: AppConstants.provinces,
                    onChanged: (value) {
                      setState(() {
                        _selectedProvince = value;
                      });
                    },
                    prefixIcon: Icons.location_on_outlined,
                  ),
                ],

                const SizedBox(height: AppSizes.paddingXLarge),

                // Register Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: 'Create Account',
                      onPressed: authProvider.isLoading ? null : _register,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),

                const SizedBox(height: AppSizes.paddingMedium),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
