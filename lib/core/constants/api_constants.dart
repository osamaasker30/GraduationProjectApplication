class ApiConstants {
  // Real device: use computer's local IP on the same WiFi network
  // Emulator: use 10.0.2.2 instead
  static const String baseUrl = 'http://172.28.29.241:5058';

  // Auth
  static const String login = '/api/auth/login';
  static const String registerStudent = '/api/auth/register/student';
  static const String registerCompany = '/api/auth/register/company';
  static const String me = '/api/auth/me';

  // Dashboard
  static const String studentDashboard = '/api/dashboard/student';
  static const String companyDashboard = '/api/dashboard/company';

  // Projects (Student)
  static const String projects = '/api/projects';
  static String projectById(int id) => '/api/projects/$id';
  static String evaluateProject(int id) => '/api/projects/$id/evaluate';

  // Opportunities (public – student view)
  static const String opportunities = '/api/opportunities';
  static String opportunityById(int id) => '/api/opportunities/$id';

  // Company Opportunities CRUD
  static const String companyOpportunities = '/api/company/opportunities';
  static String companyOpportunityById(int id) =>
      '/api/company/opportunities/$id';
  static String toggleOpportunity(int id) =>
      '/api/company/opportunities/$id/toggle';

  // Applications
  static const String apply = '/api/applications/apply';
  static String applicants(int opportunityId) =>
      '/api/applications/opportunity/$opportunityId';
  static String applicantProfile(int applicationId) =>
      '/api/applications/$applicationId/profile';
  static String updateStatus(int applicationId) =>
      '/api/applications/$applicationId/status';

  // Messages
  static const String conversations = '/api/messages';
  static String messages(int applicationId) => '/api/messages/$applicationId';
  static const String sendMessage = '/api/messages/send';
  static const String messageUnread = '/api/messages/unread-count';

  // Notifications
  static const String notifications = '/api/notifications';
  static const String notificationUnread = '/api/notifications/unread-count';
  static String markRead(int id) => '/api/notifications/$id/read';

  // Profile
  static const String studentProfile = '/api/profile/student';
  static const String companyProfile = '/api/profile/company';
}
