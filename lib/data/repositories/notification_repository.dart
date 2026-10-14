import 'package:flutter/foundation.dart';
import 'package:app_flutter_verificarlo/core/constants/api_endpoints.dart';
import 'package:app_flutter_verificarlo/core/network/api_client.dart';
import 'package:app_flutter_verificarlo/data/models/notification_model.dart';

class NotificationRepository {
  final _carlo = ApiClient.carlo;
  final _verificarlo = ApiClient.instance;

  Future<List<NotificationModel>> getAll() async {
    // Try Carlo first, fall back to Verificarlo
    try {
      final response = await _carlo.get(ApiEndpoints.carloNotifications);
      final list = response.data['notifications'] as List? ?? response.data as List;
      return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Carlo notifications failed, trying Verificarlo: $e');
    }
    try {
      final response = await _verificarlo.get(ApiEndpoints.notifications);
      final list = response.data['notifications'] as List? ?? response.data as List;
      return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Verificarlo notifications also failed: $e');
      return [];
    }
  }

  Future<void> markRead(int id) async {
    try {
      await _carlo.patch(ApiEndpoints.carloNotificationRead(id));
    } catch (_) {
      await _verificarlo.patch(ApiEndpoints.notificationRead(id));
    }
  }

  Future<void> markAllRead() async {
    try {
      await _carlo.patch(ApiEndpoints.carloNotificationsReadAll);
    } catch (_) {
      await _verificarlo.patch(ApiEndpoints.notificationsReadAll);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _carlo.delete(ApiEndpoints.carloNotificationDelete(id));
    } catch (_) {
      await _verificarlo.delete(ApiEndpoints.notificationDelete(id));
    }
  }
}
