import 'package:app_flutter_verificarlo/core/constants/api_endpoints.dart';
import 'package:app_flutter_verificarlo/core/network/api_client.dart';

class ScheduleRepository {
  final _api = ApiClient.instance;

  Future<Map<String, dynamic>> getSchedule({String? date}) async {
    final response = await _api.get(
      ApiEndpoints.inspectorSchedule,
      queryParams: date != null ? {'date': date} : null,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateSchedule(Map<String, dynamic> data) async {
    await _api.patch(ApiEndpoints.inspectorSchedule, data: data);
  }
}
