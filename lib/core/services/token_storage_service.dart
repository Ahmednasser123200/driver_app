import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../constants/storage_keys.dart';

abstract interface class TokenStorageService {
  Future<void> saveAccessToken(String token, {bool persist = true});
  Future<String?> getAccessToken();
  Future<void> saveRefreshToken(String token, {bool persist = true});
  Future<String?> getRefreshToken();
  Future<void> clear();
}

@LazySingleton(as: TokenStorageService)
class TokenStorageServiceImpl implements TokenStorageService {
  final FlutterSecureStorage _storage;

  String? _inMemoryAccessToken;
  String? _inMemoryRefreshToken;

  TokenStorageServiceImpl(this._storage);

  @override
  Future<void> saveAccessToken(String token, {bool persist = true}) async {
    _inMemoryAccessToken = token;
    if (persist) {
      await _storage.write(key: StorageKeys.kUserToken, value: token);
    } else {
      await _storage.delete(key: StorageKeys.kUserToken);
    }
  }

  @override
  Future<String?> getAccessToken() async {
    if (_inMemoryAccessToken != null && _inMemoryAccessToken!.isNotEmpty) {
      return _inMemoryAccessToken;
    }
    final token = await _storage.read(key: StorageKeys.kUserToken);
    _inMemoryAccessToken = token;
    return token;
  }

  @override
  Future<void> saveRefreshToken(String token, {bool persist = true}) async {
    _inMemoryRefreshToken = token;
    if (persist) {
      await _storage.write(key: StorageKeys.kRefreshToken, value: token);
    } else {
      await _storage.delete(key: StorageKeys.kRefreshToken);
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    if (_inMemoryRefreshToken != null && _inMemoryRefreshToken!.isNotEmpty) {
      return _inMemoryRefreshToken;
    }
    final token = await _storage.read(key: StorageKeys.kRefreshToken);
    _inMemoryRefreshToken = token;
    return token;
  }

  @override
  Future<void> clear() async {
    _inMemoryAccessToken = null;
    _inMemoryRefreshToken = null;
    await _storage.deleteAll();
  }
}