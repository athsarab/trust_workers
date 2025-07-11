class ApiConfig {
  // Change this to your actual server URL when you deploy
  // For Android emulator: use 10.0.2.2 instead of localhost
  // For web/desktop: use localhost
  static const String baseUrl = 'http://10.0.2.2/trust_workers_api';

  // API Endpoints
  static const String register = '$baseUrl/auth/register.php';
  static const String login = '$baseUrl/auth/login.php';
  static const String logout = '$baseUrl/auth/logout.php';
  static const String getUserProfile = '$baseUrl/auth/profile.php';
  static const String updateProfile = '$baseUrl/auth/update_profile.php';

  // Job endpoints
  static const String createJob = '$baseUrl/jobs/create.php';
  static const String getJobs = '$baseUrl/jobs/list.php';
  static const String getJobsByCategory = '$baseUrl/jobs/by_category.php';
  static const String getMyJobs = '$baseUrl/jobs/my_jobs.php';
  static const String updateJob = '$baseUrl/jobs/update.php';
  static const String deleteJob = '$baseUrl/jobs/delete.php';

  // Worker endpoints
  static const String getWorkers = '$baseUrl/workers/list.php';
  static const String getWorkersByCategory = '$baseUrl/workers/by_category.php';
  static const String searchWorkers = '$baseUrl/workers/search.php';

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> getAuthHeaders(String token) => {
        ...headers,
        'Authorization': 'Bearer $token',
      };
}
