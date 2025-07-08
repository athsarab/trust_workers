import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/job_post.dart';
import '../../utils/constants.dart';
import '../../widgets/job_card.dart';
import '../../widgets/empty_state.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<JobPost> _myJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyJobs();
  }

  void _loadMyJobs() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser != null) {
      _databaseService.getJobPostsByUser(currentUser.id).listen((jobs) {
        if (mounted) {
          setState(() {
            _myJobs = jobs;
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Job Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMyJobs,
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final currentUser = authProvider.currentUser;

          if (currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_myJobs.isEmpty) {
            return const EmptyState(
              icon: Icons.work_outline,
              title: 'No Job Posts',
              message:
                  'You haven\'t created any job posts yet. Create your first job post to find workers!',
            );
          }

          return Column(
            children: [
              // Header with stats
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                color: AppColors.primaryColor.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(
                      Icons.work,
                      color: AppColors.primaryColor,
                      size: AppSizes.iconMedium,
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    Text(
                      '${_myJobs.length} job post${_myJobs.length != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${_myJobs.where((job) => job.isActive).length} active',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),

              // Jobs list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadMyJobs(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    itemCount: _myJobs.length,
                    itemBuilder: (context, index) {
                      final jobPost = _myJobs[index];
                      return JobCard(
                        jobPost: jobPost,
                        currentUser: currentUser,
                        onDelete: () => _deleteJobPost(jobPost.id),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteJobPost(String jobPostId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job Post'),
        content: const Text(
            'Are you sure you want to delete this job post? This action cannot be undone.'),
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
      try {
        await _databaseService.deleteJobPost(jobPostId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job post deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete job post: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
