import 'package:flutter/cupertino.dart';

Widget getQuickAlertDialog(context, title, content, buttonContent) {
  return CupertinoAlertDialog(
    title: Text(title),
    content: Text(content),
    actions: <Widget>[
      CupertinoDialogAction(
        child: Text(buttonContent),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )
    ],
  );
}
