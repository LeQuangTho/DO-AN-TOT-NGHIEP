import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoreSecure {
  FlutterSecureStorage? _storage;

  final _keyToken = 'token';
  final _expiresIn = 'expires_in';
  final _language = 'language';

  StoreSecure() {
    getInstance();
  }

  Future setToken(String? token) async {
    await _storage?.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage?.read(key: _keyToken);
  }

  Future setExpiresIn(String? expiresIn) async {
    await _storage?.write(key: _expiresIn, value: expiresIn);
  }

  Future<String?> getExpiresIn() async {
    return await _storage?.read(key: _expiresIn);
  }

  Future setLanguage(String? language) async {
    await _storage?.write(key: _language, value: language);
  }

  Future<String?> getLanguage() async {
    return await _storage?.read(key: _language);
  }

  getInstance() async {
    if (_storage == null) {
      _storage = const FlutterSecureStorage();
    } else {
      return;
    }
  }
}
