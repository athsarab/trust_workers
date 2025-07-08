import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/job_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/job_post.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedJobType;
  String? _selectedCategory;
  String? _selectedProvince;
  String? _selectedDistrict;

  List<String> _availableDistricts = [];

  @override
  void initState() {
    super.initState();
    // Pre-fill phone from user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser?.phone != null) {
        _phoneController.text = authProvider.currentUser!.phone;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onProvinceChanged(String? province) {
    setState(() {
      _selectedProvince = province;
      _selectedDistrict = null;
      _availableDistricts = province != null
          ? AppConstants.districtsByProvince[province] ?? []
          : [];
    });
  }

  Future<void> _createJobPost() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedJobType == null ||
          _selectedCategory == null ||
          _selectedProvince == null ||
          _selectedDistrict == null) {
        Fluttertoast.showToast(
          msg: 'Please fill all required fields',
          backgroundColor: AppColors.error,
          textColor: AppColors.onPrimary,
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        Fluttertoast.showToast(
          msg: 'Please sign in to create a job post',
          backgroundColor: AppColors.error,
          textColor: AppColors.onPrimary,
        );
        return;
      }

      final jobPost = JobPost(
        id: '', // Will be set by Firestore
        title: _titleController.text.trim(),
        jobType: _selectedJobType!,
        category: _selectedCategory!,
        district: _selectedDistrict!,
        description: _descriptionController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        postedBy: currentUser.id,
        createdAt: DateTime.now(),
      );

      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      final success = await jobProvider.createJobPost(jobPost);

      if (success && mounted) {
        Fluttertoast.showToast(
          msg: 'Job post created successfully!',
          backgroundColor: Colors.green,
          textColor: AppColors.onPrimary,
        );
        _clearForm();
      } else if (jobProvider.errorMessage != null) {
        Fluttertoast.showToast(
          msg: jobProvider.errorMessage!,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: AppColors.error,
          textColor: AppColors.onPrimary,
        );
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedJobType = null;
      _selectedCategory = null;
      _selectedProvince = null;
      _selectedDistrict = null;
      _availableDistricts = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    size: 48,
                    color: AppColors.onPrimary,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Text(
                    'Create Job Post',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Find the perfect worker for your needs',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onPrimary.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.paddingLarge),

            // Job Title
            CustomTextField(
              controller: _titleController,
              labelText: 'Job Title',
              prefixIcon: Icons.title,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a job title';
                }
                if (value.length < 5) {
                  return 'Job title must be at least 5 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Job Type and Category in a row
            Row(
              children: [
                Expanded(
                  child: CustomDropdown<String>(
                    labelText: 'Job Type',
                    value: _selectedJobType,
                    items: AppConstants.jobTypes,
                    onChanged: (value) {
                      setState(() {
                        _selectedJobType = value;
                      });
                    },
                    prefixIcon: Icons.schedule,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: CustomDropdown<String>(
                    labelText: 'Category',
                    value: _selectedCategory,
                    items: AppConstants.jobCategories,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    prefixIcon: Icons.work_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Province and District in a row
            Row(
              children: [
                Expanded(
                  child: CustomDropdown<String>(
                    labelText: 'Province',
                    value: _selectedProvince,
                    items: AppConstants.provinces,
                    onChanged: _onProvinceChanged,
                    prefixIcon: Icons.location_on_outlined,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: CustomDropdown<String>(
                    labelText: 'District',
                    value: _selectedDistrict,
                    items: _availableDistricts,
                    onChanged: (value) {
                      setState(() {
                        _selectedDistrict = value;
                      });
                    },
                    prefixIcon: Icons.location_city,
                    enabled: _availableDistricts.isNotEmpty,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Description
            CustomTextField(
              controller: _descriptionController,
              labelText: 'Job Description',
              prefixIcon: Icons.description,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a job description';
                }
                if (value.length < 20) {
                  return 'Description must be at least 20 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Contact Phone
            CustomTextField(
              controller: _phoneController,
              labelText: 'Contact Phone',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a contact phone number';
                }
                if (value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSizes.paddingXLarge),

            // Create Button
            Consumer<JobProvider>(
              builder: (context, jobProvider, child) {
                return CustomButton(
                  text: 'Create Job Post',
                  onPressed: jobProvider.isLoading ? null : _createJobPost,
                  isLoading: jobProvider.isLoading,
                  icon: Icons.add,
                );
              },
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Clear Form Button
            OutlinedButton.icon(
              onPressed: _clearForm,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Form'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                  vertical: AppSizes.paddingMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
