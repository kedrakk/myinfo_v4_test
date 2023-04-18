import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showLoadingDialog(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return const AlertDialog(
        content: CircularProgressIndicator(),
      );
    },
  );
}

closeDialog(BuildContext context) {
  Navigator.of(context).pop();
}
