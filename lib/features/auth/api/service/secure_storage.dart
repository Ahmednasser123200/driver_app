import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/storage_keys.dart';

@lazySingleton
class SecureStorageService {
  final FlutterSecureStorage _storage;

  String? _inMemoryAccessToken;
  String? _inMemoryRefreshToken;

  SecureStorageService(this._storage);

  Future<void> saveAccessToken(String token, {bool rememberMe = true}) async {
    _inMemoryAccessToken = token;
    if (rememberMe) {
      await _storage.write(key: StorageKeys.kUserToken, value: token);
    } else {
      await _storage.delete(key: StorageKeys.kUserToken);
    }
  }

  Future<String?> getAccessToken() async {
    if (_inMemoryAccessToken != null && _inMemoryAccessToken!.isNotEmpty) {
      return _inMemoryAccessToken;
    }
    final token = await _storage.read(key: StorageKeys.kUserToken);
    _inMemoryAccessToken = token;
    return token;
  }

  Future<void> saveRefreshToken(String token, {bool rememberMe = true}) async {
    _inMemoryRefreshToken = token;
    if (rememberMe) {
      await _storage.write(key: StorageKeys.kRefreshToken, value: token);
    } else {
      await _storage.delete(key: StorageKeys.kRefreshToken);
    }
  }

  Future<String?> getRefreshToken() async {
    if (_inMemoryRefreshToken != null && _inMemoryRefreshToken!.isNotEmpty) {
      return _inMemoryRefreshToken;
    }
    final token = await _storage.read(key: StorageKeys.kRefreshToken);
    _inMemoryRefreshToken = token;
    return token;
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
    _inMemoryAccessToken = null;
    _inMemoryRefreshToken = null;
    await _storage.deleteAll();
  }
}
