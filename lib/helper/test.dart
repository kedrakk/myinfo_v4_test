// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:pointycastle/digests/sha256.dart';
// import 'package:pointycastle/pointycastle.dart';
// import 'package:jose/jose.dart';

// String generateAth(String accessToken) {
//   final sha256 = SHA256Digest();
//   final accessTokenBytes = Uint8List.fromList(utf8.encode(accessToken));
//   final sha256AccessToken = sha256.process(accessTokenBytes);

//   final base64URLEncodedHash = base64Url
//       .encode(sha256AccessToken)
//       .replaceAll('+', '-')
//       .replaceAll('/', '_')
//       .replaceAll('=', '');
//   return base64URLEncodedHash;
// }

// Future<String> generateDpopProof(
//     String url, String method, dynamic sessionPopKeyPair,
//     [String? ath]) async {
//   try {
//     final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

//     final payload = {
//       "htu": url,
//       "htm": method,
//       "jti": generateRandomString(40),
//       "iat": now,
//       "exp": now + 120,
//     };

//     //required only for /Person resource call
//     if (ath != null) payload['ath'] = ath;

//     final privateKey =
//         await JsonWebKey.fromPem(sessionPopKeyPair['privateKey']);
//     final publicKey = await JsonWebKey.fromPem(sessionPopKeyPair['publicKey']);
//     final jwk = publicKey.toJson()
//       ..['use'] = 'sig'
//       ..['alg'] = 'ES256';

//     final jwtBuilder = await JsonWebSignatureBuilder()
//       ..jsonContent = payload
//       ..addRecipient(privateKey, algorithm: 'ES256')
//       ..setProtectedHeader(
//         "jwk",
//         JsonWebKeySet.fromKeys(
//           [publicKey],
//         ),
//       );
//     final jwtToken = jwtBuilder.build().toCompactSerialization();
//     return jwtToken;
//   } catch (error) {
//     print('generateDpop error: $error');
//     throw 'ERROR_GENERATE_DPOP';
//   }
// }
