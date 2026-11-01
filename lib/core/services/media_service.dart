abstract interface class MediaService {
  Future<String?> pickImageFromGallery();
  Future<String?> pickImageFromCamera();
}
