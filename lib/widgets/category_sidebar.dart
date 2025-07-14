import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../screens/workers/category_workers_screen.dart';

class CategorySidebar extends StatelessWidget {
  const CategorySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.category,
                      size: 48,
                      color: AppColors.onPrimary,
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    Text(
                      'Job Categories ',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      'Find workers by category',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onPrimary.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Categories List
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
              itemCount: AppConstants.jobCategories.length,
              itemBuilder: (context, index) {
                final category = AppConstants.jobCategories[index];
                return _CategoryTile(
                  category: category,
                  icon: _getCategoryIcon(category),
                  onTap: () => _onCategoryTap(context, category),
                );
              },
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.people, color: AppColors.primaryColor),
                  title: const Text('All Workers'),
                  onTap: () => _onAllWorkersTap(context),
                ),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.error),
                      title: const Text('Sign Out'),
                      onTap: () => _onSignOut(context, authProvider),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'nanny':
        return Icons.child_care;
      case 'house cleaner':
        return Icons.cleaning_services;
      case 'carpenter':
        return Icons.carpenter;
      case 'mason':
        return Icons.construction;
      case 'electrician':
        return Icons.electrical_services;
      case 'plumber':
        return Icons.plumbing;
      case 'painter':
        return Icons.format_paint;
      case 'gardener':
        return Icons.grass;
      case 'security guard':
        return Icons.security;
      case 'cook':
        return Icons.restaurant;
      case 'driver':
        return Icons.drive_eta;
      case 'mechanic':
        return Icons.build;
      default:
        return Icons.work;
    }
  }

  void _onCategoryTap(BuildContext context, String category) {
    Navigator.of(context).pop(); // Close drawer

    // Navigate to category workers screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryWorkersScreen(category: category),
      ),
    );
  }

  void _onAllWorkersTap(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer

    // Show all workers
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    jobProvider.getAllWorkers();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            const CategoryWorkersScreen(category: 'All Workers'),
      ),
    );
  }

  void _onSignOut(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close drawer
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String category;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        final isSelected = jobProvider.selectedCategory == category;

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingSmall,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: ListTile(
            leading: Icon(
              icon,
              color:
                  isSelected ? AppColors.primaryColor : AppColors.textSecondary,
            ),
            title: Text(
              category,
              style: TextStyle(
                color:
                    isSelected ? AppColors.primaryColor : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            onTap: onTap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
        );
      },
    );
  }
}
