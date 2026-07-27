import 'package:app_flutter_verificarlo/core/constants/api_endpoints.dart';
import 'package:app_flutter_verificarlo/core/network/api_client.dart';

class UserRepository {
  final _api = ApiClient.instance;

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _api.get(ApiEndpoints.userProfile);
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _api.patch(ApiEndpoints.userProfile, data: data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.post(ApiEndpoints.changePassword, data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
