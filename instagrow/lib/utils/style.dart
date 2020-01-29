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

  static Color activeColor(context) {
    return _dynamicColor(
      context,
      CupertinoColors.activeBlue.color,
      CupertinoColors.destructiveRed,
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
      color: activeColor(context),
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
      color: dynamicGray(context),
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

  static TextStyle dataFromDate(context) {
    return TextStyle(
      fontSize: 16,
      color: _defaultText(context),
    );
  }

  static TextStyle datePickerButton(context) {
    return TextStyle(
      fontSize: 16,
      color: activeColor(context),
    );
  }

  static TextStyle datePickerText(context) {
    return TextStyle(
      fontSize: 20,
      color: _defaultText(context),
    );
  }

  static TextStyle navigationBarTextActive(context) {
    return TextStyle(color: activeColor(context));
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

  static TextStyle graphTitle(context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: _defaultText(context),
    );
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
    return _dynamicColor(
      context,
      Color.fromARGB(255, 224, 224, 224),
      Color.fromARGB(255, 78, 78, 78),
    );
  }

  static const Color overlayFiller = Color.fromARGB(128, 0, 0, 0);

  static const Color scaffoldBackground = Color.fromARGB(255, 240, 240, 240);

  static Color searchBackground(context) {
    return _dynamicColor(context, Color.fromARGB(255, 240, 240, 240),
        Color.fromARGB(255, 18, 18, 18));
  }

  static Color textFieldBackground(context) {
    return _dynamicColor(context, CupertinoColors.white,
        Color.fromARGB(255, 18, 18, 18));
  }

  static BoxDecoration textFieldDecoration(context) {
    return BoxDecoration(color: textFieldBackground(context));
  }

  static Color profileEditBackground(context) {
    return _dynamicColor(context, Color.fromARGB(255, 224, 224, 224), CupertinoColors.black);
  }

  static Color navigationBarBackground(context) {
    return _dynamicColor(context, Color.fromARGB(255, 249, 249, 249),
        Color.fromARGB(255, 27, 27, 27));
  }

  static TextStyle segmentControl = TextStyle(
    fontSize: 14,
  );

  static Color segmentControlSelected(context) => activeColor(context);
  static Color segmentControlPressed(context) => _dynamicColor(
        context,
        Color.fromARGB(128, 0, 122, 255),
        Color.fromARGB(128, 255, 69, 58),
      );

  static Color searchCursorColor = Color.fromRGBO(128, 128, 128, 1);

  static const Color searchIconColor = Color.fromRGBO(128, 128, 128, 1);
}
