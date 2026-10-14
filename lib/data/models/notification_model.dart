// ponytail: backend envía hora Lima sin zona, parsear como local
DateTime _parseLima(String s) =>
    DateTime.parse(s.endsWith('Z') ? s.substring(0, s.length - 1) : s);

class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final int? bookingId;
  final int? reportId;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.bookingId,
    this.reportId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id'] as int,
        type: json['type'] as String? ?? '',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        isRead: json['isRead'] as bool? ?? false,
        createdAt: _parseLima(json['createdAt'] as String),
        bookingId: json['bookingId'] as int?,
        reportId: json['reportId'] as int?,
      );
}
