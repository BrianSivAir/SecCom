import 'package:encrypt/encrypt.dart';

class CypherService {
  String encrypt(String key, String plainText) {
    final iv = IV.fromSecureRandom(16);
    print('key = $key');
    print('iv = ${iv.base16}');
    final encrypter = Encrypter(AES(Key.fromBase64(key)));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    print(encrypted.base64 + iv.base16);
    print('encrypted = ${encrypted.base64}');
    return encrypted.base64 + iv.base16;
  }

  String decrypt(String key, String cypherText) {
    print(cypherText);
    final iv = IV.fromBase16(cypherText.substring(cypherText.length - 32));
    print('key = $key');
    print('iv = ${iv.base16}');
    final encryptedMessage = cypherText.substring(0, cypherText.length - 32);
    print('encrypted = $encryptedMessage');
    final encrypter = Encrypter(AES(Key.fromBase64(key)));
    final decrypted = encrypter.decrypt(Encrypted.fromBase64(encryptedMessage), iv: iv);
    return decrypted;
  }

  String generateKey() {
    final key = Key.fromSecureRandom(32).base64;
    return key;
  }

}