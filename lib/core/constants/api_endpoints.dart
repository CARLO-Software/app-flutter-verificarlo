class ApiEndpoints {
  // Verificarlo = backend principal (reports, bookings, schedule, etc.)
  static const String baseUrl = 'https://www.verificarlo.com';

  // Carlo = auth centralizado + inspecciones
  static const String carloBaseUrl = 'https://carlo.pe';

  // Next.js service (PDF generation)
  static const String nextBaseUrl = 'https://www.verificarlo.com';
  static const String nextApiKey =
      '6d425be6d6365effde745937e8d04d3c4ada7513eb024946f0f294123098070f';
  static String reportPdf(int bookingId) =>
      '/api/inspections/$bookingId/report/pdf';

  // Auth (va a Carlo, que sincroniza con Verificarlo)
  static const String login = '/api/login';

  // Reports / Dashboard (Verificarlo)
  static const String reports = '/api/reports';
  static String reportById(int id) => '/api/reports/$id';
  static String reportSections(int id) => '/api/reports/$id/sections';
  static String reportComplete(int id) => '/api/reports/$id/complete';
  static String reportPhotosUpload(int id) => '/api/reports/$id/photos/upload';

  // Vehicle Inspections (Verificarlo)
  static const String vehicleInspections = '/api/vehicle-inspections';
  static String mechanicAction(int id) =>
      '/api/vehicle-inspections/$id/mechanic';

  // Vehicle Inspections (Carlo)
  static String carloMechanicAction(int id) =>
      '/api/v1/inspections/$id/mechanic';

  // Booking (Verificarlo)
  static String bookingComplete(int id) => '/api/bookings/$id/complete';
  static String bookingVehicle(int id) => '/api/bookings/$id/vehicle';

  // Inspector Schedule (Verificarlo)
  static const String inspectorSchedule = '/api/inspector/schedule';

  // Notifications (Verificarlo)
  static const String notifications = '/api/notifications';
  static String notificationRead(int id) => '/api/notifications/$id/read';
  static const String notificationsReadAll = '/api/notifications/all/read';
  static String notificationDelete(int id) => '/api/notifications/$id';

  // User (Verificarlo)
  static const String userProfile = '/api/user/profile';
  static const String changePassword = '/api/user/change-password';

  // Photos (Verificarlo)
  static String photoDelete(int id) => '/api/photos/$id';

  // Device / FCM (Verificarlo)
  static const String deviceRegister = '/api/devices/register';
  static const String deviceUnregister = '/api/devices/unregister';
}
