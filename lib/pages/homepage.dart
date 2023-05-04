// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:test_myinfo_v4/controller/myinfo_controller.dart';
import 'package:test_myinfo_v4/data/const.dart';
import 'package:test_myinfo_v4/di/main_di.dart';
import 'package:test_myinfo_v4/utils/launch_helper.dart';
import 'package:test_myinfo_v4/utils/loading.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.abc,
            ),
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          child: Image.asset(
            img,
            width: 300,
          ),
          onTap: () async {
            showLoadingDialog(context);
            final res = await MyInfoController(
              myInfoRepo: myInfoRepo,
            ).authorise();
            closeDialog(context);
            if (res != null) {
              launchToBrowser(res);
            }
          },
        ),
      ),
    );
  }
}
