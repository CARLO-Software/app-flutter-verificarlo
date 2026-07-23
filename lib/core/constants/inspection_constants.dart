class InspectionConstants {
  static const String timezone = 'America/Lima'; // UTC-5
  static const int inspectionDurationMinutes = 60;

  static const List<String> weekdaySlots = [
    '09:00', '10:00', '11:00', '12:00',
    '14:00', '15:00', '16:00', '17:00',
  ];

  static const List<String> saturdaySlots = [
    '09:00', '10:00', '11:00', '12:00',
  ];

  static const List<String> feriadosFijos = [
    '01-01', '05-01', '06-29', '07-28', '07-29',
    '08-30', '10-08', '11-01', '12-08', '12-25',
  ];
}
