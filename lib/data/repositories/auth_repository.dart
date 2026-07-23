import 'dart:convert';
import 'package:app_flutter_verificarlo/core/constants/api_endpoints.dart';
import 'package:app_flutter_verificarlo/core/network/api_client.dart';
import 'package:app_flutter_verificarlo/core/storage/secure_storage.dart';
import 'package:app_flutter_verificarlo/data/models/user_model.dart';

class AuthRepository {
  final _api = ApiClient.instance;

  Future<UserModel> login(String email, String password) async {
    final response = await _api.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    final data = response.data;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user']);

    await SecureStorage.saveToken(token);
    await SecureStorage.saveUser(jsonEncode(user.toJson()));

    return user;
  }

  Future<UserModel?> getSavedUser() async {
    final userJson = await SecureStorage.getUser();
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }

  Future<bool> isLoggedIn() async {
    final token = await SecureStorage.getToken();
    return token != null;
  }

  Future<void> logout() async {
    await SecureStorage.clearAll();
  }
}
