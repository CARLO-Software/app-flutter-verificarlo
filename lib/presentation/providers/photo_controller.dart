import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_flutter_verificarlo/data/repositories/photo_repository.dart';

final photoRepositoryProvider = Provider((_) => PhotoRepository());

class PhotoController {
  final PhotoRepository _repo;
  final ImagePicker _picker = ImagePicker();

  PhotoController(this._repo);

  Future<String?> capturePhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 80,
    );
    return file?.path;
  }

  Future<String?> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    return file?.path;
  }

  Future<String?> uploadPhoto(int reportId, String filePath, String? itemId) async {
    try {
      final photo = await _repo.upload(reportId, filePath, itemId);
      return photo.url;
    } catch (_) {
      return null;
    }
  }

  Future<bool> deletePhoto(int photoId) async {
    try {
      await _repo.delete(photoId);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final photoControllerProvider = Provider((ref) {
  return PhotoController(ref.read(photoRepositoryProvider));
});
