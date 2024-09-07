import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart';

class EncryptionRepository {
// Generates a random RSA key pair.
  Map<encrypt.Key, RSAPrivateKey> generateRSAKeyPair() {
    final keyParams =
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 12);
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seed = List<int>.generate(32, (_) => random.nextInt(255));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seed)));
    final rngParams = ParametersWithRandom(keyParams, secureRandom);
    final k = RSAKeyGenerator();
    k.init(rngParams);
    final pair = k.generateKeyPair();
    final publicKey = pair.publicKey as RSAPublicKey;
    final privateKey = pair.privateKey as RSAPrivateKey;
    return {
      encrypt.Key(Uint8List.fromList(
          publicKey.modulus!.toRadixString(16).codeUnits)): privateKey,
      encrypt.Key(Uint8List.fromList(
          privateKey.modulus!.toRadixString(16).codeUnits)): privateKey,
    };
  }

  /// Encrypts a string using AES.
  String encryptAES(String plainText, Uint8List key) {
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(
        encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  /// Encrypts a string using RSA.
  String encryptRSA(String plainText, RSAPublicKey key) {
    final encrypter = encrypt.Encrypter(encrypt.RSA(publicKey: key));

    final encrypted = encrypter.encrypt(plainText);
    return encrypted.base64;
  }

// RSAPublicKey parseRSAPublicKey(String keyString) {
//   final keyBytes = encrypt.Encrypted.parse(keyString).content;
//   final keyData = pc.RSAPublicKeyParser().parse(keyBytes);
//   return RSAPublicKey(
//     keyData.modulus,
//     keyData.publicExponent,
//   );
// }
}
