import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

@module
abstract class AppModule {
  @lazySingleton
  AssetBundle get assetBundle => rootBundle;
  @lazySingleton
  ImagePicker get imagePicker => ImagePicker();
}
