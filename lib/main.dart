import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_flutter_verificarlo/core/storage/local_storage.dart';
import 'package:app_flutter_verificarlo/core/services/fcm_service.dart';
import 'package:app_flutter_verificarlo/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FcmService.instance.init();
  await initializeDateFormatting('es');
  await LocalStorage.init();
  runApp(const ProviderScope(child: VerificarloApp()));
}
