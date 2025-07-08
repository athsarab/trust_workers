import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/worker_card.dart';
import '../../widgets/empty_state.dart';

class CategoryWorkersScreen extends StatefulWidget {
  final String category;

  const CategoryWorkersScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryWorkersScreen> createState() => _CategoryWorkersScreenState();
}

class _CategoryWorkersScreenState extends State<CategoryWorkersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      if (widget.category == 'All Workers') {
        jobProvider.getAllWorkers();
      } else {
        jobProvider.getWorkersByCategory(widget.category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, child) {
          if (jobProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (jobProvider.workers.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline,
              title: 'No Workers Found',
              message: widget.category == 'All Workers'
                  ? 'There are no workers registered yet.'
                  : 'There are no workers registered in the ${widget.category} category yet.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (widget.category == 'All Workers') {
                jobProvider.getAllWorkers();
              } else {
                jobProvider.getWorkersByCategory(widget.category);
              }
            },
            child: Column(
              children: [
                // Header with count
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  color: AppColors.primaryColor.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people,
                        color: AppColors.primaryColor,
                        size: AppSizes.iconMedium,
                      ),
                      const SizedBox(width: AppSizes.paddingSmall),
                      Text(
                        '${jobProvider.workers.length} worker${jobProvider.workers.length != 1 ? 's' : ''} found',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                      ),
                    ],
                  ),
                ),

                // Workers list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    itemCount: jobProvider.workers.length,
                    itemBuilder: (context, index) {
                      final worker = jobProvider.workers[index];
                      return WorkerCard(worker: worker);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
