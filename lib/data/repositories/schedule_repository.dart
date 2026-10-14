import 'package:app_flutter_verificarlo/core/constants/api_endpoints.dart';
import 'package:app_flutter_verificarlo/core/network/api_client.dart';
import 'package:app_flutter_verificarlo/data/models/booking_model.dart';

class ScheduleRepository {
  final _carlo = ApiClient.carlo;

  Future<List<BookingModel>> getSchedule({required String date}) async {
    final response = await _carlo.get(
      ApiEndpoints.reports,
      queryParams: {'date': date},
    );
    final list = response.data['inspections'] as List? ?? [];
    return list.map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
