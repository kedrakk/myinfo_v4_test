import 'dart:convert';
import 'dart:math';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/services.dart';
import 'package:jose/jose.dart';
import 'package:pkce/pkce.dart';
import 'package:pointycastle/export.dart';

mixin MyInfoHelper {
  static PkcePair generateCodeVerifier() {
    return PkcePair.generate();
  }

  static AsymmetricKeyPair<PublicKey, PrivateKey> generateEphemeralKeys() {
    var options = ECKeyGeneratorParameters(ECCurve_prime256v1());
    var keyGenerator = ECKeyGenerator();
    keyGenerator.init(ParametersWithRandom(options, getSecureRandom()));
    var ephemeralKeyPair = keyGenerator.generateKeyPair();

    return ephemeralKeyPair;
  }

  static SecureRandom getSecureRandom() {
    var secureRandom = FortunaRandom();
    var random = Random.secure();
    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  static String generateDpop(
    String url,
    String method,
    JsonWebKey publicJWK,
    JsonWebKey privateJWK, {
    String? ath,
  }) {
    var now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    var payload = {
      'htu': url,
      'htm': method,
      'jti': generateRandomString(40),
      'iat': now,
      'exp': now + 120,
    };

    if (ath != null) {
      payload['ath'] = ath;
    }

    var builder = JsonWebSignatureBuilder()
      ..jsonContent = payload
      ..addRecipient(privateJWK, algorithm: 'ES256')
      ..setProtectedHeader('typ', 'dpop+jwt')
      ..setProtectedHeader('alg', 'ES256')
      ..setProtectedHeader(
        'jwk',
        publicJWK.toJson(),
      );

    var dpop = builder.build().toCompactSerialization();

    return dpop;
  }

  static JsonWebKey parseKeyPem(
    AsymmetricKeyPair keyPair, {
    required bool isPrivate,
  }) {
    if (isPrivate) {
      var ecPrivateKey = keyPair.privateKey as ECPrivateKey;
      var privatePEM = CryptoUtils.encodeEcPrivateKeyToPem(ecPrivateKey);

      var privateJWK = JsonWebKey.fromPem(
        privatePEM,
        keyId: keyID(),
      );

      // var kid = generateJwkThumbprint(privateJWK);

      // //! add kid
      // var jwk = privateJWK.toJson();
      // var newJWK = Map<String, dynamic>.from(jwk);
      // newJWK['kid'] = kid;
      // var finalResult = JsonWebKey.fromJson(newJWK);

      return privateJWK;
    } else {
      var ecPublicKey = keyPair.publicKey as ECPublicKey;
      var publicPEM = CryptoUtils.encodeEcPublicKeyToPem(ecPublicKey);
      var publicJWK = JsonWebKey.fromPem(
        publicPEM,
        keyId: keyID(),
      );
      // var kid = generateJwkThumbprint(publicJWK);

      // //! add two new fields
      var jwk = publicJWK.toJson();
      var newJWK = Map<String, dynamic>.from(jwk);
      newJWK['use'] = 'sig';
      newJWK['alg'] = 'ES256';
      // newJWK['kid'] = kid;
      var finalResult = JsonWebKey.fromJson(newJWK);
      return finalResult;
    }
  }

  static Future<JsonWebKey> localKeyToPem(String resName) async {
    var data = await rootBundle.loadString(resName);
    var jwkRaw = JsonWebKey.fromPem(
      data,
    );
    //var kid = generateJwkThumbprint(jwkRaw);
    var jsonFormat = jwkRaw.toJson();
    Map<String, dynamic> newJson = {};
    newJson.addAll(jsonFormat);
    newJson["use"] = "sig";
    //newJson['kid'] = kid;
    var jwk = JsonWebKey.fromJson(newJson);
    return jwk;
  }

  static String keyID() {
    //return "AFMnnKRWTaBYEhNfEB6iQ5ErC1yqGVyZchH8A7nl_yM";
    return generateRandomString(43);
  }

  static String generateRandomString(int length) {
    var rand = Random.secure();
    var values = List<int>.generate(length, (i) => rand.nextInt(256));
    return base64Url.encode(values);
  }

  static String generateJwkThumbprint(JsonWebKey jwkey) {
    // var sha256 = SHA256Digest();
    // var jwkThumbprintBuffer = sha256.process(
    //   Uint8List.fromList(
    //     utf8.encode(
    //       jsonEncode(
    //         jwkey.toJson(),
    //       ),
    //     ),
    //   ),
    // );
    // var jwkThumbprint = base64Url.encode(jwkThumbprintBuffer);
    // return jwkThumbprint;
    return jwkey.keyId ?? "";
    // var jwk = jwkey.toJson();
    // var res1 = JsonWebTokenClaims.fromJson(jwk);
    // var res2 = res1.toBytes();
    // var res3 = sha256.convert(res2).bytes;
    // var res4 = base64.encode(res3);
    // return res4;
  }

  static String generateClientAssertion(
    String url,
    String clientId,
    JsonWebKey jwsKey,
    String jktThumbprint, {
    required JsonWebKey publicJWK,
  }) {
    var now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();

    var payload = {
      'sub': clientId,
      'jti': generateRandomString(40),
      'aud': url,
      'iss': clientId,
      'iat': now,
      'exp': now + 300,
      'cnf': {'jkt': jktThumbprint}
    };
    var builder = JsonWebSignatureBuilder()
      ..jsonContent = payload
      ..addRecipient(jwsKey, algorithm: 'ES256')
      ..setProtectedHeader('typ', 'JWT')
      ..setProtectedHeader('kid', jwsKey.keyId);

    var jwtToken = builder.build().toCompactSerialization();

    return jwtToken;
  }
}
