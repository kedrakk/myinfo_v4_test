// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:test_myinfo_v4/controller/myinfo_controller.dart';
import 'package:test_myinfo_v4/data/const.dart';
import 'package:test_myinfo_v4/repo/myinfo_repo.dart';
import 'package:test_myinfo_v4/utils/launch_helper.dart';
import 'package:test_myinfo_v4/utils/loading.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          child: Image.asset(
            img,
            width: 300,
          ),
          onTap: () async {
            showLoadingDialog(context);
            final url = await MyInfoController(
              myInfoRepo: MyInfoRepo(),
            ).authorise();
            closeDialog(context);
            if (url != null) {
              launchToBrowser(url);
            }
          },
        ),
      ),
    );
  }
}
