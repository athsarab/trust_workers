import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_post.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Job Posts Collection
  CollectionReference get jobPosts => _firestore.collection('job_posts');

  // Users Collection
  CollectionReference get users => _firestore.collection('users');

  // Create a new job post
  Future<void> createJobPost(JobPost jobPost) async {
    try {
      await jobPosts.add(jobPost.toMap());
    } catch (e) {
      throw Exception('Failed to create job post: ${e.toString()}');
    }
  }

  // Get all job posts
  Stream<List<JobPost>> getAllJobPosts() {
    return jobPosts
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return JobPost.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get job posts by category
  Stream<List<JobPost>> getJobPostsByCategory(String category) {
    return jobPosts
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return JobPost.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get job posts by user
  Stream<List<JobPost>> getJobPostsByUser(String userId) {
    return jobPosts
        .where('postedBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return JobPost.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Update job post
  Future<void> updateJobPost(
      String jobPostId, Map<String, dynamic> data) async {
    try {
      await jobPosts.doc(jobPostId).update(data);
    } catch (e) {
      throw Exception('Failed to update job post: ${e.toString()}');
    }
  }

  // Delete job post (soft delete)
  Future<void> deleteJobPost(String jobPostId) async {
    try {
      await jobPosts.doc(jobPostId).update({'isActive': false});
    } catch (e) {
      throw Exception('Failed to delete job post: ${e.toString()}');
    }
  }

  // Get workers by category
  Stream<List<UserModel>> getWorkersByCategory(String category) {
    return users
        .where('userType', isEqualTo: UserType.worker.toString())
        .where('jobCategory', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get all workers
  Stream<List<UserModel>> getAllWorkers() {
    return users
        .where('userType', isEqualTo: UserType.worker.toString())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Search job posts
  Future<List<JobPost>> searchJobPosts(String query) async {
    try {
      final snapshot = await jobPosts.where('isActive', isEqualTo: true).get();

      return snapshot.docs
          .map((doc) =>
              JobPost.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((jobPost) =>
              jobPost.title.toLowerCase().contains(query.toLowerCase()) ||
              jobPost.description.toLowerCase().contains(query.toLowerCase()) ||
              jobPost.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search job posts: ${e.toString()}');
    }
  }

  // Search workers
  Future<List<UserModel>> searchWorkers(String query) async {
    try {
      final snapshot = await users
          .where('userType', isEqualTo: UserType.worker.toString())
          .get();

      return snapshot.docs
          .map((doc) =>
              UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((worker) =>
              worker.name.toLowerCase().contains(query.toLowerCase()) ||
              (worker.jobCategory
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ??
                  false))
          .toList();
    } catch (e) {
      throw Exception('Failed to search workers: ${e.toString()}');
    }
  }
}
