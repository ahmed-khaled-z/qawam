import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart';

/// Generates an RSA 2048-bit key pair.
AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRsaKeyPair() {
  final keyGen = RSAKeyGenerator();
  final params = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 12);
  final secureRandom = FortunaRandom();
  final seedSource = Random.secure();
  final seeds = List<int>.generate(32, (_) => seedSource.nextInt(256));
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
  keyGen.init(ParametersWithRandom(params, secureRandom));
  final pair = keyGen.generateKeyPair();
  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
    pair.publicKey as RSAPublicKey,
    pair.privateKey as RSAPrivateKey,
  );
}

/// Encodes RSAPublicKey to PEM (PKCS#1 format).
String encodePublicKeyToPem(RSAPublicKey key) {
  final seq = ASN1Sequence()
    ..add(ASN1Integer(key.modulus!))
    ..add(ASN1Integer(key.exponent!));
  final bytes = seq.encodedBytes;
  return _toPem(bytes, '-----BEGIN RSA PUBLIC KEY-----', '-----END RSA PUBLIC KEY-----');
}

/// Encodes RSAPrivateKey to PEM (PKCS#1 format).
/// [publicExponent] is the public exponent e (e.g. 65537).
String encodePrivateKeyToPem(RSAPrivateKey key, BigInt publicExponent) {
  final dP = key.exponent! % (key.p! - BigInt.one);
  final dQ = key.exponent! % (key.q! - BigInt.one);
  final qInv = key.q!.modInverse(key.p!);

  final seq = ASN1Sequence()
    ..add(ASN1Integer(BigInt.zero))
    ..add(ASN1Integer(key.modulus!))
    ..add(ASN1Integer(publicExponent))
    ..add(ASN1Integer(key.exponent!))
    ..add(ASN1Integer(key.p!))
    ..add(ASN1Integer(key.q!))
    ..add(ASN1Integer(dP))
    ..add(ASN1Integer(dQ))
    ..add(ASN1Integer(qInv));
  final bytes = seq.encodedBytes;
  return _toPem(bytes, '-----BEGIN RSA PRIVATE KEY-----', '-----END RSA PRIVATE KEY-----');
}

String _toPem(Uint8List bytes, String header, String footer) {
  final b64 = base64.encode(bytes);
  final lines = <String>[header];
  for (var i = 0; i < b64.length; i += 64) {
    lines.add(b64.substring(i, i + 64 > b64.length ? b64.length : i + 64));
  }
  lines.add(footer);
  return lines.join('\n');
}

/// Parses a PEM string to RSA public or private key (from encrypt's parser).
RSAAsymmetricKey parseKeyFromPem(String pem) {
  final parser = encrypt.RSAKeyParser();
  return parser.parse(pem);
}
