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
}
