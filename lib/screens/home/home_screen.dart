import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../utils/constants.dart';
import '../jobs/job_list_screen.dart';
import '../jobs/create_job_screen.dart';
import '../workers/workers_list_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../widgets/category_sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize data
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      jobProvider.getAllJobPosts();
    });
  }

  List<Widget> _getScreensForUserType(UserType userType) {
    if (userType == UserType.worker) {
      return [
        const JobListScreen(), // Browse jobs
        const WorkersListScreen(), // Browse other workers
        const NotificationsScreen(),
        const ProfileScreen(),
      ];
    } else {
      return [
        const JobListScreen(), // Browse jobs
        const CreateJobScreen(), // Create job posts
        const NotificationsScreen(),
        const ProfileScreen(),
      ];
    }
  }

  List<BottomNavigationBarItem> _getBottomNavItemsForUserType(
      UserType userType) {
    if (userType == UserType.worker) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          activeIcon: Icon(Icons.work),
          label: 'Jobs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Workers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          activeIcon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: 'Post Job',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          activeIcon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser;

        if (currentUser == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final screens = _getScreensForUserType(currentUser.userType);
        final bottomNavItems =
            _getBottomNavItemsForUserType(currentUser.userType);

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(_getAppBarTitle()),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _showSearchDialog(),
              ),
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: AppColors.textSecondary,
            items: bottomNavItems,
          ),
          endDrawer: const CategorySidebar(),
        );
      },
    );
  }

  String _getAppBarTitle() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser?.userType == UserType.worker) {
      switch (_currentIndex) {
        case 0:
          return 'Available Jobs';
        case 1:
          return 'Other Workers';
        case 2:
          return 'Notifications';
        case 3:
          return 'Profile';
        default:
          return 'Trust Workers';
      }
    } else {
      switch (_currentIndex) {
        case 0:
          return 'Trust Workers';
        case 1:
          return 'Post a Job';
        case 2:
          return 'Notifications';
        case 3:
          return 'Profile';
        default:
          return 'Trust Workers';
      }
    }
  }

  void _showSearchDialog() {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search jobs or workers...',
                prefixIcon: Icon(Icons.search),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                Navigator.of(context).pop();
                _performSearch(searchController.text);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser?.userType == UserType.worker) {
      jobProvider.searchJobPosts(query);
      setState(() {
        _currentIndex = 0; // Switch to jobs tab
      });
    } else {
      jobProvider.searchWorkers(query);
      // For normal users, we could navigate to a workers view or show results
    }
  }
}
