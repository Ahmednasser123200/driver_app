
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';


import '../../../../core/constants/storage_keys.dart';

@lazySingleton
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: StorageKeys.kUserToken, value: token);}

    Future<String?> getAccessToken() async {
      return _storage.read(key: StorageKeys.kUserToken);
    }

    Future<void> saveRefreshToken(String token) async {
      await _storage.write(key: StorageKeys.kRefreshToken, value: token);
    }

    Future<String?> getRefreshToken() async {
      return _storage.read(key: StorageKeys.kRefreshToken);
    }

    Future<void> saveRememberedEmail(String email) async {
      await _storage.write(key: StorageKeys.kRememberedEmail, value: email);
    }

    Future<String?> getRememberedEmail() async {
      return _storage.read(key: StorageKeys.kRememberedEmail);
    }

    Future<void> deleteRememberedEmail() async {
      await _storage.delete(key: StorageKeys.kRememberedEmail);
    }

    Future<void> clear() async {
      await _storage.deleteAll();
    }
  }

