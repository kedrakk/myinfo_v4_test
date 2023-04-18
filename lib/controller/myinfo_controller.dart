import 'dart:developer';

import 'package:pkce/pkce.dart';
import 'package:test_myinfo_v4/repo/myinfo_repo.dart';

class MyInfoController {
  final MyInfoRepo myInfoRepo;
  MyInfoController({
    required this.myInfoRepo,
  });
  PkcePair generateCodeVerifier() {
    return PkcePair.generate();
  }

  Future<String?> authorise() async {
    try {
      PkcePair pair = generateCodeVerifier();
      var res = await myInfoRepo.authorise(pkcePair: pair);
      return res;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
