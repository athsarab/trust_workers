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
  Future<void> getAllJobPosts() async {
    _setLoading(true);
    _clearError();

    try {
      _jobPosts = await _databaseService.getAllJobPosts();
      _setLoading(false);
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
    }
  }

  // Get job posts by category
  Future<void> getJobPostsByCategory(String category) async {
    _setLoading(true);
    _clearError();
    _selectedCategory = category;

    try {
      _jobPosts = await _databaseService.getJobPostsByCategory(category);
      _setLoading(false);
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
    }
  }

  // Get workers by category
  Future<void> getWorkersByCategory(String category) async {
    _setLoading(true);
    _clearError();
    _selectedCategory = category;

    try {
      _workers = await _databaseService.getWorkersByCategory(category);
      _setLoading(false);
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
    }
  }

  // Get all workers
  Future<void> getAllWorkers() async {
    _setLoading(true);
    _clearError();

    try {
      _workers = await _databaseService.getAllWorkers();
      _setLoading(false);
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
    }
  }

  // Get job posts by user
  Future<void> getJobPostsByUser(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _jobPosts = await _databaseService.getJobPostsByUser(userId);
      _setLoading(false);
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
    }
  }

  // Create job post
  Future<bool> createJobPost(JobPost jobPost) async {
    _setLoading(true);
    _clearError();

    try {
      await _databaseService.createJobPost(jobPost);
      // Refresh the job posts list
      await getAllJobPosts();
      return true;
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update job post
  Future<bool> updateJobPost(
      String jobPostId, Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();

    try {
      await _databaseService.updateJobPost(jobPostId, data);
      // Refresh the job posts list
      await getAllJobPosts();
      return true;
    } catch (error) {
      _setError(error.toString());
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
      // Refresh the job posts list
      await getAllJobPosts();
      return true;
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
      return false;
    }
  }

  // Search job posts
  Future<void> searchJobPosts(String query) async {
    _setLoading(true);
    _clearError();

    try {
      _jobPosts = await _databaseService.searchJobPosts(query);
      _setLoading(false);
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
    }
  }

  // Search workers
  Future<void> searchWorkers(String query) async {
    _setLoading(true);
    _clearError();

    try {
      _workers = await _databaseService.searchWorkers(query);
      _setLoading(false);
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
    }
  }

  // Filter jobs by province
  List<JobPost> getJobsByProvince(String province) {
    return _jobPosts.where((job) => job.district == province).toList();
  }

  // Filter workers by province
  List<UserModel> getWorkersByProvince(String province) {
    return _workers.where((worker) => worker.province == province).toList();
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

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
