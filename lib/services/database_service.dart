import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_post.dart';
import '../models/user_model.dart';
import '../utils/api_config.dart';

class DatabaseService {
  // Get auth token from SharedPreferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Create a new job post
  Future<void> createJobPost(JobPost jobPost) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse(ApiConfig.createJob),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode(jobPost.toMap()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 && response.statusCode != 201 ||
          data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to create job post');
      }
    } catch (e) {
      throw Exception('Failed to create job post: ${e.toString()}');
    }
  }

  // Get all job posts
  Future<List<JobPost>> getAllJobPosts() async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse(ApiConfig.getJobs),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> jobsData = data['jobs'];
        return jobsData
            .map(
                (jobData) => JobPost.fromMap(jobData, jobData['id'].toString()))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch jobs');
      }
    } catch (e) {
      throw Exception('Failed to get job posts: ${e.toString()}');
    }
  }

  // Get job posts by category
  Future<List<JobPost>> getJobPostsByCategory(String category) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse(
            '${ApiConfig.getJobsByCategory}?category=${Uri.encodeComponent(category)}'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> jobsData = data['jobs'];
        return jobsData
            .map(
                (jobData) => JobPost.fromMap(jobData, jobData['id'].toString()))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch jobs by category');
      }
    } catch (e) {
      throw Exception('Failed to get job posts by category: ${e.toString()}');
    }
  }

  // Get job posts by user
  Future<List<JobPost>> getJobPostsByUser(String userId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse(
            '${ApiConfig.getMyJobs}?user_id=${Uri.encodeComponent(userId)}'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> jobsData = data['jobs'];
        return jobsData
            .map(
                (jobData) => JobPost.fromMap(jobData, jobData['id'].toString()))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch user jobs');
      }
    } catch (e) {
      throw Exception('Failed to get job posts by user: ${e.toString()}');
    }
  }

  // Update job post
  Future<void> updateJobPost(
      String jobPostId, Map<String, dynamic> data) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.put(
        Uri.parse(
            '${ApiConfig.updateJob}?id=${Uri.encodeComponent(jobPostId)}'),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode != 200 || responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'Failed to update job post');
      }
    } catch (e) {
      throw Exception('Failed to update job post: ${e.toString()}');
    }
  }

  // Delete job post (soft delete)
  Future<void> deleteJobPost(String jobPostId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.delete(
        Uri.parse(
            '${ApiConfig.deleteJob}?id=${Uri.encodeComponent(jobPostId)}'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to delete job post');
      }
    } catch (e) {
      throw Exception('Failed to delete job post: ${e.toString()}');
    }
  }

  // Get workers by category
  Future<List<UserModel>> getWorkersByCategory(String category) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse(
            '${ApiConfig.getWorkersByCategory}?category=${Uri.encodeComponent(category)}'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> workersData = data['workers'];
        return workersData
            .map((workerData) =>
                UserModel.fromMap(workerData, workerData['id'].toString()))
            .toList();
      } else {
        throw Exception(
            data['message'] ?? 'Failed to fetch workers by category');
      }
    } catch (e) {
      throw Exception('Failed to get workers by category: ${e.toString()}');
    }
  }

  // Get all workers
  Future<List<UserModel>> getAllWorkers() async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse(ApiConfig.getWorkers),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> workersData = data['workers'];
        return workersData
            .map((workerData) =>
                UserModel.fromMap(workerData, workerData['id'].toString()))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch workers');
      }
    } catch (e) {
      throw Exception('Failed to get all workers: ${e.toString()}');
    }
  }

  // Search job posts
  Future<List<JobPost>> searchJobPosts(String query) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/jobs/search.php?q=${Uri.encodeComponent(query)}'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> jobsData = data['jobs'];
        return jobsData
            .map(
                (jobData) => JobPost.fromMap(jobData, jobData['id'].toString()))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to search jobs');
      }
    } catch (e) {
      throw Exception('Failed to search job posts: ${e.toString()}');
    }
  }

  // Search workers
  Future<List<UserModel>> searchWorkers(String query) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('${ApiConfig.searchWorkers}?q=${Uri.encodeComponent(query)}'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> workersData = data['workers'];
        return workersData
            .map((workerData) =>
                UserModel.fromMap(workerData, workerData['id'].toString()))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to search workers');
      }
    } catch (e) {
      throw Exception('Failed to search workers: ${e.toString()}');
    }
  }
}
