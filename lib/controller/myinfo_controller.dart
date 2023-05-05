import 'dart:developer';
import 'package:jose/jose.dart';
import 'package:pkce/pkce.dart';
import 'package:test_myinfo_v4/helper/myinfo_helper.dart';
import 'package:test_myinfo_v4/helper/shared_prefs_helper.dart';
import 'package:test_myinfo_v4/repo/myinfo_repo.dart';

import '../data/const.dart';

class MyInfoController {
  final MyInfoRepo myInfoRepo;
  MyInfoController({
    required this.myInfoRepo,
  });

  Future<String?> authorise() async {
    try {
      PkcePair pair = MyInfoHelper.generateCodeVerifier();
      var res = await myInfoRepo.authorise(pkcePair: pair);
      await SFHelper().storeString(
        key: SFKeys().codeVerifier,
        value: pair.codeVerifier,
      );
      return res;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<String> getToken({
    required String code,
  }) async {
    var url = "$backendURL/token";
    var method = "POST";
    var publicJWK = JsonWebKey.fromJson(
      {
        "alg": "ES256",
        "crv": "P-256",
        "kid": "aQPyZ72NM043E4KEioaHWzixt0owV99gC9kRK388WoQ",
        "kty": "EC",
        "use": "sig",
        "x": "BXUWq0Z2RRFqrlWbW2muIybNnj_YBxflNQTEOg-QmCQ",
        "y": "vXO4G4yDo0iOVJAzmEWyIZwXwnSnGxPIrZe7SX0PKu4"
      },
    );
    var localPrivateJWK = await MyInfoHelper.localKeyToPem(signingKeyPath);
    var dpop = MyInfoHelper.generateDpop(
      url,
      method,
      publicJWK,
      localPrivateJWK,
    );
    var jwkThumbprint = MyInfoHelper.generateJwkThumbprint(publicJWK);

    var clientAssertion = MyInfoHelper.generateClientAssertion(
      url,
      clientId,
      localPrivateJWK,
      jwkThumbprint,
      publicJWK: publicJWK,
    );
    String codeVerifier = await SFHelper().getString(
          key: SFKeys().codeVerifier,
        ) ??
        "";
    try {
      var res = await myInfoRepo.getToken(
        dpop: dpop,
        authCode: code,
        clientAssertion: clientAssertion,
        codeVerifier: codeVerifier,
      );
      return res;
    } catch (e) {
      log(e.toString());
      return e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> getJWKS() async {
    try {
      var res = await myInfoRepo.getJWKS();
      return res;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getKeys() async {
    try {
      var res = await myInfoRepo.getJWKS();
      return res;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<String> getPersonData({
    required String bearerToken,
  }) async {
    //get keys
    var jsonKeys = await getKeys();
    if (jsonKeys.isEmpty) {
      return "";
    }

    var jsonWebKeyStore = MyInfoHelper.convertMapsToJWKStore(jsonKeys);
    var sub = await MyInfoHelper.verifyAccessToken(
      bearerToken,
      jsonWebKeyStore,
    );

    var ath = MyInfoHelper.digestSha256(bearerToken);

    var url = "$backendURL/person/$sub";
    var method = "GET";
    var publicJWK = JsonWebKey.fromJson(
      {
        "alg": "ES256",
        "crv": "P-256",
        "kid": "aQPyZ72NM043E4KEioaHWzixt0owV99gC9kRK388WoQ",
        "kty": "EC",
        "use": "sig",
        "x": "BXUWq0Z2RRFqrlWbW2muIybNnj_YBxflNQTEOg-QmCQ",
        "y": "vXO4G4yDo0iOVJAzmEWyIZwXwnSnGxPIrZe7SX0PKu4"
      },
    );
    var localPrivateJWK = await MyInfoHelper.localKeyToPem(signingKeyPath);
    var dpop = MyInfoHelper.generateDpop(
      url,
      method,
      publicJWK,
      localPrivateJWK,
      ath: ath,
    );
    try {
      var res = await myInfoRepo.getPersonData(
        dpop: dpop,
        authorization: "DPoP $bearerToken",
        sub: sub,
      );
      return res;
    } catch (e) {
      log(e.toString());
      return e.toString();
    }
  }
}
