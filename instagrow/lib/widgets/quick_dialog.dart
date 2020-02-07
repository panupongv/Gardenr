import 'package:flutter/cupertino.dart';
import 'package:instagrow/utils/style.dart';

Widget quickAlertDialog(context, title, content, buttonContent) {
  return CupertinoAlertDialog(
    title: Text(
      title,
      style: Styles.dialogTitle(context),
    ),
    content: Text(
      content,
      style: Styles.dialogContent(context),
    ),
    actions: <Widget>[
      CupertinoDialogAction(
        child: Text(
          buttonContent,
          style: Styles.dialogActionNormal(context),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )
    ],
  );
}
