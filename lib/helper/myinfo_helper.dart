import 'dart:convert';
import 'dart:math';
import 'package:basic_utils/basic_utils.dart';
import 'package:crypto/crypto.dart';
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
      payload.addAll(
        {
          'ath': ath,
        },
      );
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

      return privateJWK;
    } else {
      var ecPublicKey = keyPair.publicKey as ECPublicKey;
      var publicPEM = CryptoUtils.encodeEcPublicKeyToPem(ecPublicKey);
      var publicJWK = JsonWebKey.fromPem(
        publicPEM,
        keyId: keyID(),
      );

      // //! add two new fields
      var jwk = publicJWK.toJson();
      var newJWK = Map<String, dynamic>.from(jwk);
      newJWK['use'] = 'sig';
      newJWK['alg'] = 'ES256';
      var finalResult = JsonWebKey.fromJson(newJWK);
      return finalResult;
    }
  }

  static Future<JsonWebKey> localKeyToPem(String resName) async {
    var data = await rootBundle.loadString(resName);
    var jwkRaw = JsonWebKey.fromPem(
      data,
    );
    var jsonFormat = jwkRaw.toJson();
    Map<String, dynamic> newJson = {};
    newJson.addAll(jsonFormat);
    newJson["use"] = "sig";
    var jwk = JsonWebKey.fromJson(newJson);
    return jwk;
  }

  static String keyID() {
    return generateRandomString(43);
  }

  static String generateRandomString(int length) {
    var rand = Random.secure();
    var values = List<int>.generate(length, (i) => rand.nextInt(256));
    return base64Url.encode(values);
  }

  static String generateJwkThumbprint(JsonWebKey jwkey) {
    return jwkey.keyId ?? "";
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

  static JsonWebKeyStore convertMapsToJWKStore(
    List<Map<String, dynamic>> keysMap,
  ) {
    JsonWebKeyStore jsonWebKeyStore = JsonWebKeyStore();
    for (var element in keysMap) {
      jsonWebKeyStore.addKey(
        JsonWebKey.fromJson(
          element,
        ),
      );
    }
    return jsonWebKeyStore;
  }

  static Future<String> verifyAccessToken(
    String accessToken,
    JsonWebKeyStore jsonWebKeyStore,
  ) async {
    final jwsData = JsonWebSignature.fromCompactSerialization(accessToken);
    final isVerify = await jwsData.verify(jsonWebKeyStore);
    if (isVerify) {
      final josePayload = await jwsData.getPayload(jsonWebKeyStore);
      var jsonPayload = jsonDecode(josePayload.stringContent);
      var subData = jsonPayload["sub"];
      return subData;
    } else {
      return "";
    }
  }

  static String digestSha256(String input) {
    List<int> sha256AccessToken = sha256.convert(utf8.encode(input)).bytes;
    String base64URLEncodedHash = base64Url
        .encode(sha256AccessToken)
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');
    return base64URLEncodedHash;
  }
}
