import 'dart:convert';

import 'package:pkce/pkce.dart';
import 'package:test_myinfo_v4/data/const.dart';
import 'package:http/http.dart' as http;

class MyInfoRepo {
  Future<String> authorise({
    required PkcePair pkcePair,
  }) async {
    var verifyURL =
        "$backendURL/authorize?client_id=$clientId&scope=$scope&purpose_id=$purpose&code_challenge=${pkcePair.codeVerifier}&code_challenge_method=$codeChallengeMethod&response_type=$responseType&redirect_uri=$callBackURL";
    var returnURL =
        "$backendURL/authorize?client_id=$clientId&scope=$scope&purpose_id=$purpose&code_challenge=${pkcePair.codeChallenge}&code_challenge_method=$codeChallengeMethod&response_type=$responseType&redirect_uri=$callBackURL";

    try {
      var response = await http.get(
        Uri.parse(verifyURL),
      );
      if (response.statusCode == 200) {
        return returnURL;
      }
      throw Exception(response.body.toString());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getJWKS() async {
    var url = authoriseJWKSURL;
    try {
      var response = await http.get(
        Uri.parse(url),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var dynamicListData = data["keys"] as List<dynamic>;
        List<Map<String, dynamic>> maplistData = [];
        for (var element in dynamicListData) {
          maplistData.add(element);
        }
        return maplistData;
      }
      throw Exception(response.body.toString());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> getToken({
    required String dpop,
    required String authCode,
    required String clientAssertion,
    required String codeVerifier,
  }) async {
    var url = "$backendURL/token";

    try {
      var headers = {
        "Content-Type": "application/x-www-form-urlencoded",
        "DPoP": dpop,
      };
      var body = {
        "code": authCode,
        "grant_type": "authorization_code",
        "client_id": clientId,
        "redirect_uri": callBackURL,
        "client_assertion": clientAssertion,
        "client_assertion_type": clientAssertionType,
        "code_verifier": codeVerifier,
      };
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        return body["access_token"];
      }
      throw Exception(response.body.toString());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> getPersonData({
    required String dpop,
    required String authorization,
    required String sub,
  }) async {
    var url = "$backendURL/person/$sub?scope=$scope";
    var headers = {
      "Authorization": authorization,
      "DPoP": dpop,
    };
    try {
      var response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return response.body;
      }
      print(response.body);
      throw Exception(response.body.toString());
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
