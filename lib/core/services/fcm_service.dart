import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:app_flutter_verificarlo/core/network/api_client.dart';
import 'package:app_flutter_verificarlo/core/constants/api_endpoints.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM Background: ${message.messageId}');
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  static FcmService get instance => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _token;
  Function(Map<String, dynamic>)? onInspectionReceived;

  String? get token => _token;

  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _getToken();
      _setupListeners();
    }
  }

  Future<void> _getToken() async {
    _token = await _messaging.getToken();
    debugPrint('FCM Token: $_token');

    _messaging.onTokenRefresh.listen((newToken) {
      _token = newToken;
      _registerTokenWithBackend();
    });
  }

  void _setupListeners() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    _checkInitialMessage();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FCM Foreground: ${message.notification?.title}');
    _processMessage(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('FCM Opened App: ${message.notification?.title}');
    _processMessage(message);
  }

  Future<void> _checkInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      _processMessage(message);
    }
  }

  void _processMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] ?? '';

    // ponytail: accept any inspection-related push, not just new_inspection
    if (type.contains('inspection') && onInspectionReceived != null) {
      onInspectionReceived!(data);
    }
  }

  Future<void> registerToken() async {
    if (_token == null) return;
    await _registerTokenWithBackend();
  }

  Future<void> _registerTokenWithBackend() async {
    if (_token == null) return;

    try {
      await ApiClient.instance.post(
        ApiEndpoints.deviceRegister,
        data: {'token': _token},
      );
      debugPrint('FCM Token registered with backend');
    } catch (e) {
      debugPrint('Error registering FCM token: $e');
    }
  }

  Future<void> unregisterToken() async {
    if (_token == null) return;

    try {
      await ApiClient.instance.delete(ApiEndpoints.deviceUnregister);
      debugPrint('FCM Token unregistered');
    } catch (e) {
      debugPrint('Error unregistering FCM token: $e');
    }
  }
}
