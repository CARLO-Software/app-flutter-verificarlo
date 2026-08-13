import 'package:flutter/foundation.dart';
import 'package:app_flutter_verificarlo/core/constants/api_endpoints.dart';
import 'package:app_flutter_verificarlo/core/network/api_client.dart';
import 'package:app_flutter_verificarlo/data/models/booking_model.dart';

class InspectionRepository {
  final _api = ApiClient.instance;

  Future<List<BookingModel>> getPendingInspections() async {
    final response = await _api.get(
      ApiEndpoints.reports,
      queryParams: {'status': 'pending'},
    );
    final list = response.data['inspections'] as List;
    if (list.isNotEmpty) {
      debugPrint('Booking JSON sample: ${list.first}');
    }
    return list.map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<List<BookingModel>> getCompletedInspections() async {
    final response = await _api.get(
      ApiEndpoints.reports,
      queryParams: {'status': 'completed'},
    );
    final list = response.data['inspections'] as List;
    return list.map((e) => BookingModel.fromJson(e)).toList();
  }
}
