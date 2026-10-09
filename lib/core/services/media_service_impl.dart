import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import 'media_service.dart';

@LazySingleton(as: MediaService)
class MediaServiceImpl implements MediaService {
  final ImagePicker _picker;

  MediaServiceImpl(this._picker);

  @override
  Future<String?> pickImageFromGallery() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    return file?.path;
  }

  @override
  Future<String?> pickImageFromCamera() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.camera);
    return file?.path;
  }
}
