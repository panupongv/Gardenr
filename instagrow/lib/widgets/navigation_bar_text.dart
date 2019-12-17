import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Text navigationBarTitle(String title) {
  return Text(
    title,
    style: TextStyle(fontSize: 20),
  );
}

GestureDetector navigationBarTextButton(String text, Function onTapCallback) {
  return GestureDetector(
    child: Text(
      text,
      style: TextStyle(color: CupertinoColors.activeBlue),
    ),
    onTap: onTapCallback,
  );
}
