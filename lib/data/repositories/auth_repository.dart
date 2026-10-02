import 'dart:convert';
import 'package:app_flutter_verificarlo/core/constants/api_endpoints.dart';
import 'package:app_flutter_verificarlo/core/network/api_client.dart';
import 'package:app_flutter_verificarlo/core/storage/secure_storage.dart';
import 'package:app_flutter_verificarlo/data/models/user_model.dart';

class AuthRepository {
  Future<UserModel> login(String email, String password) async {
    // Login va a Carlo (sincroniza con Verificarlo internamente)
    final response = await ApiClient.carlo.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    final data = response.data;
    final carloToken = data['token'] as String;
    final verificarloToken = data['verificarloToken'] as String?;
    final user = UserModel.fromJson(data['user']);

    await SecureStorage.saveCarloToken(carloToken);

    if (verificarloToken != null) {
      await SecureStorage.saveToken(verificarloToken);
    }

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
