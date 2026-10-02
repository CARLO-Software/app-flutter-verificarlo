import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:app_flutter_verificarlo/core/constants/api_endpoints.dart';
import 'package:app_flutter_verificarlo/core/storage/secure_storage.dart';
import 'package:app_flutter_verificarlo/core/network/api_exception.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._('verificarlo', ApiEndpoints.baseUrl, SecureStorage.getToken);
  static ApiClient get instance => _instance;

  static final ApiClient _carlo = ApiClient._('carlo', ApiEndpoints.carloBaseUrl, SecureStorage.getCarloToken);
  static ApiClient get carlo => _carlo;

  late final Dio dio;
  final String _label;

  ApiClient._(this._label, String baseUrl, Future<String?> Function() tokenGetter) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenGetter();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        debugPrint('[$_label] ${options.method} ${options.path}');
        handler.next(options);
      },
      onError: (error, handler) {
        debugPrint('[$_label] ERROR ${error.response?.statusCode} on ${error.requestOptions.path}: ${error.response?.data}');
        handler.next(error);
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      return await dio.get(path, queryParameters: queryParams);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException e) {
    final data = e.response?.data;
    final message = data is Map ? (data['error'] ?? data['message'] ?? 'Error desconocido') : 'Error de conexión';
    return ApiException(message.toString(), statusCode: e.response?.statusCode);
  }
}
