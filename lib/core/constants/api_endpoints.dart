class ApiEndpoints {
  static const String baseUrl = 'https://www.verificarlo.com';

  // Auth
  static const String login = '/api/login';

  // Reports / Dashboard
  static const String reports = '/api/reports';
  static String reportById(int id) => '/api/reports/$id';
  static String reportSections(int id) => '/api/reports/$id/sections';
  static String reportComplete(int id) => '/api/reports/$id/complete';
  static String reportPhotosUpload(int id) => '/api/reports/$id/photos/upload';

  // Vehicle Inspections
  static const String vehicleInspections = '/api/vehicle-inspections';
  static String mechanicAction(int id) =>
      '/api/vehicle-inspections/$id/mechanic';

  // Booking completion
  static String bookingComplete(int id) => '/api/bookings/$id/complete';

  // Inspector Schedule
  static const String inspectorSchedule = '/api/inspector/schedule';

  // Notifications
  static const String notifications = '/api/notifications';
  static String notificationRead(int id) => '/api/notifications/$id/read';
  static const String notificationsReadAll = '/api/notifications/all/read';
  static String notificationDelete(int id) => '/api/notifications/$id';

  // User
  static const String userProfile = '/api/user/profile';
  static const String changePassword = '/api/user/change-password';

  // Photos
  static String photoDelete(int id) => '/api/photos/$id';

  // Device / FCM
  static const String deviceRegister = '/api/devices/register';
  static const String deviceUnregister = '/api/devices/unregister';
}
