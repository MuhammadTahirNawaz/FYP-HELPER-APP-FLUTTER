import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/app_logger.dart';

/// Loads AES key material from platform secure storage.
///
/// Production apps should provision keys from a KMS / backend and never ship
/// defaults in source. For this FYP proof-of-concept, the first launch seeds
/// the secure vault with coursework defaults so existing encrypted data keeps working.
class CryptoKeyStore {
  CryptoKeyStore._();

  static const _storageKey = 'aes_secret_key';
  static const _storageIv = 'aes_init_vector';

  /// Coursework fallback — used only to seed the vault on first install.
  /// In production, delete these constants and fetch keys from secure backend.
  static const String _seedKey = 'fyp_helper_app_key_32_bytes_1234';
  static const String _seedIv = 'fyp_helper_iv16x';

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    wOptions: WindowsOptions(),
  );

  static String? _key;
  static String? _iv;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Must be called once during [main] before any encryption/decryption.
  static Future<void> initialize() async {
    if (_initialized) return;

    var key = await _secureStorage.read(key: _storageKey);
    var iv = await _secureStorage.read(key: _storageIv);

    if (key == null || iv == null) {
      await _secureStorage.write(key: _storageKey, value: _seedKey);
      await _secureStorage.write(key: _storageIv, value: _seedIv);
      key = _seedKey;
      iv = _seedIv;
      AppLogger.debug(
        'Seeded AES key material into flutter_secure_storage (first launch).',
        tag: 'CRYPTO',
      );
    } else {
      AppLogger.debug(
        'Loaded AES key material from flutter_secure_storage.',
        tag: 'CRYPTO',
      );
    }

    _key = key;
    _iv = iv;
    _initialized = true;
  }

  static String get key {
    _assertReady();
    return _key!;
  }

  static String get iv {
    _assertReady();
    return _iv!;
  }

  static void _assertReady() {
    if (!_initialized || _key == null || _iv == null) {
      throw StateError(
        'CryptoKeyStore.initialize() must be called before using CryptoService.',
      );
    }
  }
}
