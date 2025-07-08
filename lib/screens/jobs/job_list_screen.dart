import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../widgets/job_card.dart';
import '../../widgets/empty_state.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      jobProvider.getAllJobPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<JobProvider, AuthProvider>(
      builder: (context, jobProvider, authProvider, child) {
        final currentUser = authProvider.currentUser;

        if (currentUser == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (jobProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (jobProvider.jobPosts.isEmpty) {
          return EmptyState(
            icon: Icons.work_outline,
            title: 'No Jobs Available',
            message: currentUser.userType == UserType.worker
                ? 'There are no job posts available at the moment. Check back later!'
                : 'No job posts yet. Create your first job post!',
            actionText: currentUser.userType == UserType.normal
                ? 'Create Job Post'
                : null,
            onActionPressed: currentUser.userType == UserType.normal
                ? () => _navigateToCreateJob()
                : null,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            jobProvider.getAllJobPosts();
          },
          child: Column(
            children: [
              // Filter chips for workers
              if (currentUser.userType == UserType.worker) ...[
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingSmall),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMedium),
                    itemCount: ['All', ...AppConstants.jobCategories].length,
                    itemBuilder: (context, index) {
                      final categories = ['All', ...AppConstants.jobCategories];
                      final category = categories[index];
                      final isSelected =
                          jobProvider.selectedCategory == category ||
                              (category == 'All' &&
                                  jobProvider.selectedCategory.isEmpty);

                      return Padding(
                        padding:
                            const EdgeInsets.only(right: AppSizes.paddingSmall),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (category == 'All') {
                              jobProvider.getAllJobPosts();
                              jobProvider.setCategory('');
                            } else {
                              jobProvider.getJobPostsByCategory(category);
                            }
                          },
                          selectedColor:
                              AppColors.primaryColor.withOpacity(0.2),
                          checkmarkColor: AppColors.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
              ],

              // Jobs list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  itemCount: jobProvider.jobPosts.length,
                  itemBuilder: (context, index) {
                    final jobPost = jobProvider.jobPosts[index];
                    return JobCard(
                      jobPost: jobPost,
                      currentUser: currentUser,
                      onDelete: currentUser.userType == UserType.normal
                          ? () => _deleteJobPost(jobPost.id)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToCreateJob() {
    // This would be handled by the bottom navigation
    // For now, we can show a message or navigate manually
  }

  Future<void> _deleteJobPost(String jobPostId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job Post'),
        content: const Text('Are you sure you want to delete this job post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      await jobProvider.deleteJobPost(jobPostId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job post deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
