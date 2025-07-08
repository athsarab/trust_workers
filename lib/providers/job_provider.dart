import 'package:flutter/material.dart';
import '../models/job_post.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class JobProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<JobPost> _jobPosts = [];
  List<UserModel> _workers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = '';

  List<JobPost> get jobPosts => _jobPosts;
  List<UserModel> get workers => _workers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  // Get all job posts
  void getAllJobPosts() {
    _databaseService.getAllJobPosts().listen(
      (posts) {
        _jobPosts = posts;
        notifyListeners();
      },
      onError: (error) {
        _setError(error.toString());
      },
    );
  }

  // Get job posts by category
  void getJobPostsByCategory(String category) {
    _selectedCategory = category;
    _databaseService.getJobPostsByCategory(category).listen(
      (posts) {
        _jobPosts = posts;
        notifyListeners();
      },
      onError: (error) {
        _setError(error.toString());
      },
    );
  }

  // Get workers by category
  void getWorkersByCategory(String category) {
    _selectedCategory = category;
    _databaseService.getWorkersByCategory(category).listen(
      (workers) {
        _workers = workers;
        notifyListeners();
      },
      onError: (error) {
        _setError(error.toString());
      },
    );
  }

  // Get all workers
  void getAllWorkers() {
    _databaseService.getAllWorkers().listen(
      (workers) {
        _workers = workers;
        notifyListeners();
      },
      onError: (error) {
        _setError(error.toString());
      },
    );
  }

  // Create job post
  Future<bool> createJobPost(JobPost jobPost) async {
    _setLoading(true);
    _clearError();

    try {
      await _databaseService.createJobPost(jobPost);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Delete job post
  Future<bool> deleteJobPost(String jobPostId) async {
    _setLoading(true);
    _clearError();

    try {
      await _databaseService.deleteJobPost(jobPostId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Search job posts
  Future<void> searchJobPosts(String query) async {
    _setLoading(true);
    _clearError();

    try {
      final results = await _databaseService.searchJobPosts(query);
      _jobPosts = results;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Search workers
  Future<void> searchWorkers(String query) async {
    _setLoading(true);
    _clearError();

    try {
      final results = await _databaseService.searchWorkers(query);
      _workers = results;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
