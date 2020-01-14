// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class Styles {
  static Color _dynamicColor(
      BuildContext context, Color normalColor, Color darkModeColor) {
    return CupertinoTheme.brightnessOf(context) == Brightness.dark
        ? darkModeColor
        : normalColor;
  }

  static TextStyle navigationBarTitle(context) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color:
          _dynamicColor(context, CupertinoColors.black, CupertinoColors.white),
    );
  }

  static TextStyle dashboardItemTitle(context) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color:
          _dynamicColor(context, CupertinoColors.black, CupertinoColors.white),
    );
  }

  static TextStyle plantProfileName(context) {
    return TextStyle(
        color: _dynamicColor(
            context, CupertinoColors.black, CupertinoColors.white),
        fontSize: 20,
        fontWeight: FontWeight.bold);
  }

  static TextStyle ownerNameActive(context) {
    return TextStyle(
      fontSize: 14,
      color: CupertinoColors.activeBlue,
      decoration: TextDecoration.underline,
    );
  }

  static TextStyle ownerNameInactive(context) {
    return TextStyle(
      fontSize: 14,
      color: dynamicGray(context),
    );
  }

  static Color dynamicGray(context) {
    return _dynamicColor(
      context,
      CupertinoColors.inactiveGray.color,
      CupertinoColors.inactiveGray.darkColor,
    );
  }

  static TextStyle dashboardItemDetail(context) {
    return TextStyle(color: dynamicGray(context));
  }

  static Color separatorLine(context) {
    return _dynamicColor(context, Color(0x80E0E0E0), Color(0x80E0E0E0));
  }

  static const TextStyle productRowItemName = TextStyle(
    color: Color.fromRGBO(0, 0, 0, 0.8),
    fontSize: 18,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle productRowTotal = TextStyle(
    color: Color.fromRGBO(0, 0, 0, 0.8),
    fontSize: 18,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle productRowItemPrice = TextStyle(
    color: Color(0xFF8E8E93),
    fontSize: 13,
    fontWeight: FontWeight.w300,
  );

  static const TextStyle searchText = TextStyle(
    color: Color.fromRGBO(0, 0, 0, 1),
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle deliveryTimeLabel = TextStyle(
    color: Color(0xFFC2C2C2),
    fontWeight: FontWeight.w300,
  );

  static const TextStyle deliveryTime = TextStyle(
    color: CupertinoColors.inactiveGray,
  );

  static const Color productRowDivider = Color(0xFFD9D9D9);

  static const Color scaffoldBackground = Color(0xfff0f0f0);

  static const Color searchBackground = Color(0xffe0e0e0);

  static const Color searchCursorColor = Color.fromRGBO(0, 122, 255, 1);

  static const Color searchIconColor = Color.fromRGBO(128, 128, 128, 1);
}
