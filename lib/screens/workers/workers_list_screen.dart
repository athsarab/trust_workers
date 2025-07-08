import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/worker_card.dart';
import '../../widgets/empty_state.dart';

class WorkersListScreen extends StatefulWidget {
  const WorkersListScreen({super.key});

  @override
  State<WorkersListScreen> createState() => _WorkersListScreenState();
}

class _WorkersListScreenState extends State<WorkersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      jobProvider.getAllWorkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        if (jobProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (jobProvider.workers.isEmpty) {
          return const EmptyState(
            icon: Icons.people_outline,
            title: 'No Workers Found',
            message: 'There are no workers registered in this category yet.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            jobProvider.getAllWorkers();
          },
          child: Column(
            children: [
              // Filter chips
              Container(
                height: 60,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
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
                            jobProvider.getAllWorkers();
                            jobProvider.setCategory('');
                          } else {
                            jobProvider.getWorkersByCategory(category);
                          }
                        },
                        selectedColor: AppColors.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppColors.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),

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
    );
  }
}
