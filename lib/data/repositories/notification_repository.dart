import 'package:app_flutter_verificarlo/core/constants/api_endpoints.dart';
import 'package:app_flutter_verificarlo/core/network/api_client.dart';
import 'package:app_flutter_verificarlo/data/models/notification_model.dart';

class NotificationRepository {
  final _api = ApiClient.instance;

  Future<List<NotificationModel>> getAll() async {
    final response = await _api.get(ApiEndpoints.notifications);
    final list = response.data['notifications'] as List? ?? response.data as List;
    return list.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markRead(int id) async {
    await _api.patch(ApiEndpoints.notificationRead(id));
  }

  Future<void> markAllRead() async {
    await _api.patch(ApiEndpoints.notificationsReadAll);
  }

  Future<void> delete(int id) async {
    await _api.delete(ApiEndpoints.notificationDelete(id));
  }
}
