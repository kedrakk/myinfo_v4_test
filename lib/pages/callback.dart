// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:test_myinfo_v4/controller/myinfo_controller.dart';
import 'package:test_myinfo_v4/utils/loading.dart';

import '../di/main_di.dart';

class CallBackPage extends StatefulWidget {
  const CallBackPage({
    super.key,
    required this.code,
    required this.error,
    required this.errorDesc,
  });
  final String code, error, errorDesc;

  @override
  State<CallBackPage> createState() => _CallBackPageState();
}

class _CallBackPageState extends State<CallBackPage> {
  String bearerToken = "";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  _getData() async {
    if (widget.code.isNotEmpty) {
      showLoadingDialog(context);
      bearerToken = await MyInfoController(myInfoRepo: myInfoRepo).getToken(
        code: widget.code,
      );
      closeDialog(context);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Center(
            child: Text(
              "Code: ${widget.code}\nError: ${widget.error}\nError Desc: ${widget.errorDesc}",
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              "Bearer Token: $bearerToken",
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
