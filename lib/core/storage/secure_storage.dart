import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _carloTokenKey = 'carlo_token';
  static const _userKey = 'user_data';

  // Verificarlo token (main backend)
  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  // Carlo token
  static Future<void> saveCarloToken(String token) =>
      _storage.write(key: _carloTokenKey, value: token);

  static Future<String?> getCarloToken() =>
      _storage.read(key: _carloTokenKey);

  static Future<void> saveUser(String userJson) =>
      _storage.write(key: _userKey, value: userJson);

  static Future<String?> getUser() => _storage.read(key: _userKey);

  static Future<void> clearAll() => _storage.deleteAll();
}
