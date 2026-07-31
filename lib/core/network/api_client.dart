import 'package:dio/dio.dart';
import 'package:app_flutter_verificarlo/core/constants/api_endpoints.dart';
import 'package:app_flutter_verificarlo/core/storage/secure_storage.dart';
import 'package:app_flutter_verificarlo/core/network/api_exception.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  late final Dio dio;

  ApiClient._() {
    dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // ponytail: only clear session for non-login 401s, skip device endpoints
          final path = error.requestOptions.path;
          if (!path.contains('/devices/')) {
            SecureStorage.clearAll();
          }
        }
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
