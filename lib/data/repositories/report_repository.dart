import 'package:app_flutter_verificarlo/core/constants/api_endpoints.dart';
import 'package:app_flutter_verificarlo/core/network/api_client.dart';

class ReportRepository {
  final _api = ApiClient.instance;

  Future<Map<String, dynamic>> getReport(int id) async {
    final response = await _api.get(ApiEndpoints.reportById(id));
    return response.data as Map<String, dynamic>;
  }

  Future<void> patchReport(int id, Map<String, dynamic> data) async {
    await _api.patch(ApiEndpoints.reportById(id), data: data);
  }

  Future<void> patchSections(int id, Map<String, dynamic> sections) async {
    await _api.patch(ApiEndpoints.reportSections(id), data: sections);
  }

  Future<void> completeReport(int id, Map<String, dynamic> data) async {
    await _api.post(ApiEndpoints.reportComplete(id), data: data);
  }

  Future<void> registerPlate(int inspectionId, String plate) async {
    await _api.patch(
      ApiEndpoints.mechanicAction(inspectionId),
      data: {'action': 'register_plate', 'plate': plate},
    );
  }
}
