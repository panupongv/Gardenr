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

  static Color _defaultText(context) {
    return _dynamicColor(context, CupertinoColors.black, CupertinoColors.white);
  }

  static Color _defaultBackground(context) {
    return _dynamicColor(context, CupertinoColors.white, CupertinoColors.black);
  }

  static Color dynamicGray(context) {
    return _dynamicColor(
      context,
      CupertinoColors.inactiveGray.color,
      CupertinoColors.inactiveGray.darkColor,
    );
  }

  static Color dynamicBlue(context) {
    return _dynamicColor(
      context,
      CupertinoColors.activeBlue.color,
      CupertinoColors.activeBlue.darkColor,
    );
  }

  static TextStyle navigationBarTitle(context) {
    return TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: _defaultText(context));
  }

  static TextStyle dashboardItemTitle(context) {
    return TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _defaultText(context));
  }

  static TextStyle dashboardItemDetail(context) {
    return TextStyle(fontSize: 14, color: dynamicGray(context));
  }

  static TextStyle plantProfileName(context) {
    return TextStyle(
        color: _defaultText(context),
        fontSize: 20,
        fontWeight: FontWeight.bold);
  }

  static TextStyle ownerNameActive(context) {
    return TextStyle(
      fontSize: 14,
      color: dynamicBlue(context),
      decoration: TextDecoration.underline,
    );
  }

  static TextStyle ownerNameInactive(context) {
    return TextStyle(
      fontSize: 14,
      color: dynamicGray(context),
    );
  }

  static TextStyle plantTimeText(context) {
    return TextStyle(
      fontSize: 14,
      color: _defaultText(context),
    );
  }

  static TextStyle noDataAvailable(context) {
    return TextStyle(
      fontSize: 20,
      color: _defaultText(context),
    );
  }

  static TextStyle editFieldText(context) {
    return TextStyle(
      fontSize: 14,
      color: _defaultText(context),
    );
  }

  static TextStyle descriptionExpandableText(context) {
    return TextStyle(
      fontSize: 16,
      color: _defaultText(context),
    );
  }

  static TextStyle moreLessButton(context) {
    return TextStyle(
      fontSize: 16,
      color: Styles.dynamicGray(context),
    );
  }

  static TextStyle datePickerText(context) {
    return TextStyle(
      fontSize: 20,
      color: _defaultText(context),
    );
  }

  static TextStyle navigationBarTextActive(context) {
    return TextStyle(color: dynamicBlue(context));
  }

  static TextStyle navigationBarTextInActive(context) {
    return TextStyle(color: dynamicGray(context));
  }

  static TextStyle toggleVisible(context) {
    return TextStyle(
      color: _defaultText(context),
    );
  }

  static TextStyle logOutButton(context) {
    return TextStyle(
      fontSize: 16,
      color: CupertinoColors.destructiveRed,
    );
  }

  static Color overlayBackground(context) {
    return _defaultBackground(context);
  }

  static TextStyle searchText(context) {
    return TextStyle(
      color: _defaultText(context),
      fontSize: 14,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal,
    );
  }

  static TextStyle changeImage(context) {
    return TextStyle(
      fontSize: 14,
      color: CupertinoColors.activeBlue,
    );
  }

  static Color separatorLine(context) {
    return _dynamicColor(context, Color(0x80E0E0E0), Color(0x80E0E0E0));
  }

  static const Color overlayFiller = Color(0x80000000);

  static const Color scaffoldBackground = Color(0xfff0f0f0);

  static Color searchBackground(context) {
    return _dynamicColor(context, Color(0xffe0e0e0), Color(0xff121212));
  }

  static Color textFieldBackground(context) {
    return _dynamicColor(context, Color(0xffe0e0e0), Color(0xff121212));
  }

  static BoxDecoration testFieldDecoration(context) {
    return BoxDecoration(color: textFieldBackground(context));
  }

  static Color navigationBarBackground(context) {
    return _dynamicColor(context, Color(0xfff9f9f9), Color(0xff1b1b1b));
  }

  static TextStyle segmentControl = TextStyle(
    fontSize: 14,
  );

  static Color segmentControlSelected(context) => dynamicBlue(context);
  static Color segmentControlPressed(context) => _dynamicColor(
        context,
        Color.fromARGB(128, 0, 122, 255),
        Color.fromARGB(128, 10, 132, 255),
      );

  static Color searchCursorColor = Color.fromRGBO(128, 128, 128, 1);

  static const Color searchIconColor = Color.fromRGBO(128, 128, 128, 1);
}
