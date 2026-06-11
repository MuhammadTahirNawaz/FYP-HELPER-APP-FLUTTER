import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';

import '../utils/profiler.dart';
import 'crypto_key_store.dart';

/// Payload passed to background isolates for AES work.
class _CryptoJob {
  const _CryptoJob({
    required this.input,
    required this.key,
    required this.iv,
    required this.encrypt,
  });

  final String input;
  final String key;
  final String iv;
  final bool encrypt;
}

// Top-level functions for background execution (Isolates).
String _cryptoHeavy(_CryptoJob job) {
  final iv = encrypt.IV.fromUtf8(job.iv);
  final encrypter = encrypt.Encrypter(
    encrypt.AES(
      encrypt.Key.fromUtf8(job.key),
      mode: encrypt.AESMode.cbc,
    ),
  );

  if (job.encrypt) {
    return encrypter.encrypt(job.input, iv: iv).base64;
  }

  final encrypted = encrypt.Encrypted.fromBase64(job.input);
  return encrypter.decrypt(encrypted, iv: iv);
}

/// AES-CBC encryption for sensitive profile fields (e.g. phone numbers).
///
/// Key material is read from [CryptoKeyStore] (backed by flutter_secure_storage).
/// A production deployment would fetch rotating keys from a remote KMS instead of
/// seeding coursework defaults on first launch.
class CryptoService {
  CryptoService()
      : _iv = encrypt.IV.fromUtf8(CryptoKeyStore.iv),
        _encrypter = encrypt.Encrypter(
          encrypt.AES(
            encrypt.Key.fromUtf8(CryptoKeyStore.key),
            mode: encrypt.AESMode.cbc,
          ),
        );

  final encrypt.IV _iv;
  final encrypt.Encrypter _encrypter;

  // Synchronous methods (main thread — suitable for small strings).
  String encryptText(String input) {
    final encrypted = _encrypter.encrypt(input, iv: _iv);
    return encrypted.base64;
  }

  String decryptText(String input) {
    final encrypted = encrypt.Encrypted.fromBase64(input);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  // Asynchronous methods (background isolates + profiling).
  Future<String> encryptTextAsync(String input) {
    return Profiler.profileAsync('AES Encrypt', () {
      return compute(
        _cryptoHeavy,
        _CryptoJob(
          input: input,
          key: CryptoKeyStore.key,
          iv: CryptoKeyStore.iv,
          encrypt: true,
        ),
      );
    });
  }

  Future<String> decryptTextAsync(String input) {
    return Profiler.profileAsync('AES Decrypt', () {
      return compute(
        _cryptoHeavy,
        _CryptoJob(
          input: input,
          key: CryptoKeyStore.key,
          iv: CryptoKeyStore.iv,
          encrypt: false,
        ),
      );
    });
  }
}
