// ponytail: fuerza UTC cuando el backend omite la Z
DateTime _parseUtc(String s) =>
    DateTime.parse(s.endsWith('Z') ? s : '${s}Z').toLocal();

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
        createdAt: _parseUtc(json['createdAt'] as String),
        bookingId: json['bookingId'] as int?,
        reportId: json['reportId'] as int?,
      );
}
