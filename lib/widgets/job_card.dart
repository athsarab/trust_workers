import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/job_post.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class JobCard extends StatelessWidget {
  final JobPost jobPost;
  final UserModel currentUser;
  final VoidCallback? onDelete;

  const JobCard({
    super.key,
    required this.jobPost,
    required this.currentUser,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = currentUser.id == jobPost.postedBy;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and menu
            Row(
              children: [
                Expanded(
                  child: Text(
                    jobPost.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (isOwner && onDelete != null)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete?.call();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: AppColors.error),
                            SizedBox(width: AppSizes.paddingSmall),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingSmall),

            // Category and job type chips
            Wrap(
              spacing: AppSizes.paddingSmall,
              runSpacing: AppSizes.paddingSmall,
              children: [
                _buildChip(
                  jobPost.category,
                  Icons.work_outline,
                  AppColors.primaryColor,
                ),
                _buildChip(
                  jobPost.jobType,
                  Icons.schedule,
                  AppColors.accent,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Description
            Text(
              jobPost.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Location and contact info
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: AppSizes.iconSmall,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: Text(
                    jobPost.district,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
                Icon(
                  Icons.access_time,
                  size: AppSizes.iconSmall,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                Text(
                  _formatDate(jobPost.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Action buttons
            Row(
              children: [
                if (currentUser.userType == UserType.worker) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _callNumber(context, jobPost.contactPhone),
                      icon: const Icon(Icons.phone, size: AppSizes.iconSmall),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: AppColors.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _copyPhoneNumber(context, jobPost.contactPhone),
                    icon: const Icon(Icons.copy, size: AppSizes.iconSmall),
                    label: const Text('Copy Phone'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _callNumber(BuildContext context, String phoneNumber) {
    // In a real app, you would use url_launcher to make a phone call
    // For now, we'll show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call'),
        content: Text('Would you like to call $phoneNumber?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Here you would implement actual calling functionality
              // using url_launcher: tel:$phoneNumber
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _copyPhoneNumber(BuildContext context, String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Phone number copied: $phoneNumber'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
