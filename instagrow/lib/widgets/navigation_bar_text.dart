import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/utils/style.dart';

Text navigationBarTitle(String title) {
  return Text(
    title,
    style: TextStyle(fontSize: 20),
  );
}

GestureDetector navigationBarTextButton(
    BuildContext context, String text, Function onTapCallback) {
  return GestureDetector(
    child: Text(
      text,
      style: Styles.navigationBarTextActive(context),
    ),
    onTap: onTapCallback,
  );
}
