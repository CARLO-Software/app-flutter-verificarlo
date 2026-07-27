import 'package:dio/dio.dart';
import 'package:app_flutter_verificarlo/core/constants/api_endpoints.dart';
import 'package:app_flutter_verificarlo/core/network/api_client.dart';
import 'package:app_flutter_verificarlo/data/models/inspection_photo_model.dart';

class PhotoRepository {
  final _api = ApiClient.instance;

  Future<InspectionPhoto> upload(int reportId, String filePath, String? itemId) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath),
      if (itemId != null) 'itemId': itemId,
    });
    // ponytail: token injected by dio interceptor, just override content-type
    final response = await _api.dio.post(
      ApiEndpoints.reportPhotosUpload(reportId),
      data: formData,
    );
    return InspectionPhoto.fromJson(response.data);
  }

  Future<void> delete(int photoId) async {
    await _api.delete(ApiEndpoints.photoDelete(photoId));
  }
}
