import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../jobs/my_jobs_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser;

        if (currentUser == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(context, currentUser),

              const SizedBox(height: AppSizes.paddingLarge),

              // Stats Cards (for normal users showing job posts)
              if (currentUser.userType == UserType.normal) ...[
                _buildStatsSection(context),
                const SizedBox(height: AppSizes.paddingLarge),
              ],

              // Menu Items
              _buildMenuSection(context, currentUser),

              const SizedBox(height: AppSizes.paddingLarge),

              // Sign Out Button
              CustomButton(
                text: 'Sign Out',
                onPressed: () => _signOut(context, authProvider),
                backgroundColor: AppColors.error,
                icon: Icons.logout,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryColor,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Name
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.paddingSmall),

            // User Type Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: user.userType == UserType.worker
                    ? Colors.green.withOpacity(0.1)
                    : AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color: user.userType == UserType.worker
                      ? Colors.green
                      : AppColors.primaryColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    user.userType == UserType.worker
                        ? Icons.build
                        : Icons.person,
                    size: AppSizes.iconSmall,
                    color: user.userType == UserType.worker
                        ? Colors.green
                        : AppColors.primaryColor,
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Text(
                    user.userType == UserType.worker ? 'Worker' : 'Job Poster',
                    style: TextStyle(
                      color: user.userType == UserType.worker
                          ? Colors.green
                          : AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Contact Info
            _buildContactInfo(context, user),

            // Worker-specific info
            if (user.userType == UserType.worker) ...[
              const SizedBox(height: AppSizes.paddingMedium),
              _buildWorkerInfo(context, user),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, UserModel user) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.phone,
                size: AppSizes.iconSmall, color: AppColors.textSecondary),
            const SizedBox(width: AppSizes.paddingSmall),
            Text(
              user.phone,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Row(
          children: [
            const Icon(Icons.email,
                size: AppSizes.iconSmall, color: AppColors.textSecondary),
            const SizedBox(width: AppSizes.paddingSmall),
            Expanded(
              child: Text(
                user.email,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkerInfo(BuildContext context, UserModel user) {
    return Column(
      children: [
        if (user.jobCategory != null) ...[
          Row(
            children: [
              const Icon(Icons.work,
                  size: AppSizes.iconSmall, color: AppColors.textSecondary),
              const SizedBox(width: AppSizes.paddingSmall),
              Text(
                user.jobCategory!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
        ],
        if (user.experience != null) ...[
          Row(
            children: [
              const Icon(Icons.star,
                  size: AppSizes.iconSmall, color: AppColors.textSecondary),
              const SizedBox(width: AppSizes.paddingSmall),
              Text(
                user.experience!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
        ],
        if (user.province != null) ...[
          Row(
            children: [
              const Icon(Icons.location_on,
                  size: AppSizes.iconSmall, color: AppColors.textSecondary),
              const SizedBox(width: AppSizes.paddingSmall),
              Text(
                user.province!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Active Jobs',
                '${jobProvider.jobPosts.length}',
                Icons.work,
                AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Views',
                '0', // Placeholder
                Icons.visibility,
                Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, UserModel user) {
    return Card(
      child: Column(
        children: [
          if (user.userType == UserType.normal) ...[
            _buildMenuItem(
              context,
              'My Job Posts',
              Icons.work_outline,
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MyJobsScreen()),
              ),
            ),
            const Divider(height: 1),
          ],
          _buildMenuItem(
            context,
            'Edit Profile',
            Icons.edit,
            () => _showEditProfileDialog(context, user),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            'Settings',
            Icons.settings,
            () => _showSettingsDialog(context),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            'Help & Support',
            Icons.help_outline,
            () => _showHelpDialog(context),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            'About',
            Icons.info_outline,
            () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content:
            const Text('Profile editing feature will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings page will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('For support, please contact:'),
            SizedBox(height: 8),
            Text('Email: support@trustworkers.com'),
            Text('Phone: +94 XXX XXX XXX'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Trust Workers'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trust Workers v1.0.0'),
            SizedBox(height: 8),
            Text('Connecting Skills with Opportunities'),
            SizedBox(height: 8),
            Text('© 2025 Trust Workers. All rights reserved.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context, AuthProvider authProvider) {
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
              Navigator.of(context).pop();
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
