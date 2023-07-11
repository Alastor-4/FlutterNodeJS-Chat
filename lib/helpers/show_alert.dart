import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

showAlert(BuildContext context, String title, String subtitle) {
  if (Platform.isAndroid) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(subtitle),
        actions: [
          MaterialButton(
            child: const Text('Ok'),
            elevation: 5,
            textColor: Colors.blue,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: [
        CupertinoDialogAction(
          child: const Text('Ok'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
