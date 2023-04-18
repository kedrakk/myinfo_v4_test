import 'package:flutter/material.dart';

class CallBackPage extends StatelessWidget {
  const CallBackPage({
    super.key,
    required this.code,
    required this.error,
    required this.errorDesc,
  });
  final String code, error, errorDesc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          "Code: $code\nError: $error\nError Desc: $errorDesc",
        ),
      ),
    );
  }
}
