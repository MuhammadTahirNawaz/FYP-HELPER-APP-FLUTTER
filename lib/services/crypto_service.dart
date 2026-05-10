import 'package:encrypt/encrypt.dart' as encrypt;

class CryptoService {
  CryptoService()
      : _iv = encrypt.IV.fromUtf8(_kIv),
        _encrypter = encrypt.Encrypter(
          encrypt.AES(
            encrypt.Key.fromUtf8(_kKey),
            mode: encrypt.AESMode.cbc,
          ),
        );

  static const String _kKey = 'fyp_helper_app_key_32_bytes_1234';
  static const String _kIv = 'fyp_helper_iv16x';

  final encrypt.IV _iv;
  final encrypt.Encrypter _encrypter;

  String encryptText(String input) {
    final encrypted = _encrypter.encrypt(input, iv: _iv);
    return encrypted.base64;
  }

  String decryptText(String input) {
    final encrypted = encrypt.Encrypted.fromBase64(input);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }
}
