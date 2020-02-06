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
      CupertinoColors.activeBlue.darkColor,
    );
  }

  static TextStyle tabTitle(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 10,
    );
  }

  static TextStyle navigationBarTitle(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: _defaultText(context),
    );
  }

  static TextStyle dashboardItemTitle(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: _defaultText(context),
    );
  }

  static TextStyle dashboardItemDetail(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 15,
      color: dynamicGray(context),
    );
  }

  static TextStyle plantProfileName(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      color: _defaultText(context),
      fontSize: 17,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle ownerNameActive(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 14,
      color: activeColor(context),
      decoration: TextDecoration.underline,
    );
  }

  static TextStyle ownerNameInactive(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 14,
      color: dynamicGray(context),
    );
  }

  static TextStyle plantTimeText(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 15,
      color: dynamicGray(context),
    );
  }

  static TextStyle noDataAvailable(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 15,
      color: dynamicGray(context),
    );
  }

  static TextStyle editFieldText(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 14,
      color: _defaultText(context),
    );
  }

  static TextStyle descriptionExpandableText(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 15,
      color: _defaultText(context),
    );
  }

  static TextStyle moreLessButton(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 15,
      color: Styles.dynamicGray(context),
    );
  }

  static TextStyle dataFromDate(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 17,
      color: _defaultText(context),
    );
  }

  static TextStyle datePickerButton(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 17,
      decoration: TextDecoration.underline,
      color: activeColor(context),
    );
  }

  static TextStyle datePickerText(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 19,
      color: _defaultText(context),
    );
  }

  static TextStyle actionSheetAction(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 19,
      color: activeColor(context),
    );
  }

  static TextStyle actionSheetActionRed(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 19,
      color: _dynamicColor(
        context,
        CupertinoColors.systemRed.color,
        CupertinoColors.systemRed.darkColor,
      ),
    );
  }

  static TextStyle navigationBarTextActive(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      color: activeColor(context),
      fontSize: 17,
    );
  }

  static TextStyle navigationBarTextInActive(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      color: dynamicGray(context),
      fontSize: 17,
    );
  }

  static TextStyle toggleVisible(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      color: _defaultText(context),
    );
  }

  static TextStyle aboutUser(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 14,
      color: dynamicGray(context),
    );
  }

  static TextStyle dialogTitle(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      color: _defaultText(context),
      fontWeight: FontWeight.w600,
      fontSize: 17,
    );
  }

  static TextStyle dialogContent(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      color: _defaultText(context),
      fontSize: 13,
    );
  }

  static TextStyle dialogActionNormal(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      color: activeColor(context),
      fontSize: 17,
    );
  }

  static TextStyle dialogActionCrucial(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      color: _dynamicColor(
        context,
        CupertinoColors.systemRed.color,
        CupertinoColors.systemRed.darkColor,
      ),
      fontSize: 17,
    );
  }

  static Color overlayBackground(context) {
    return _defaultBackground(context);
  }

  static TextStyle graphTitle(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: _defaultText(context),
    );
  }

  static TextStyle searchText(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      color: _defaultText(context),
      fontSize: 17,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal,
    );
  }

  static TextStyle changeImage(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      fontSize: 14,
      color: CupertinoColors.activeBlue,
    );
  }

  static Color separatorLine(context) {
    return _dynamicColor(
      context,
      Color.fromARGB(255, 202, 202, 202),
      Color.fromARGB(255, 48, 48, 48),
    );
  }

  static const Color overlayFiller = Color.fromARGB(128, 0, 0, 0);

  static const Color scaffoldBackground = Color.fromARGB(255, 240, 240, 240);

  static Color searchBackground(context) {
    return _dynamicColor(context, Color.fromARGB(255, 240, 240, 240),
        Color.fromARGB(255, 18, 18, 18));
  }

  static Color textFieldBackground(context) {
    return _dynamicColor(
        context, CupertinoColors.white, Color.fromARGB(255, 18, 18, 18));
  }

  static TextStyle textFieldText(context) {
    return TextStyle(
      fontFamily: 'SFPro',
      color: _defaultText(context),
      fontSize: 17,
    );
  }

  static BoxDecoration textFieldDecoration(context) {
    return BoxDecoration(color: textFieldBackground(context));
  }

  static Color profileEditBackground(context) {
    return _dynamicColor(
        context, Color.fromARGB(255, 224, 224, 224), CupertinoColors.black);
  }

  static Color navigationBarBackground(context) {
    return _dynamicColor(context, Color.fromARGB(255, 249, 249, 249),
        Color.fromARGB(255, 27, 27, 27));
  }

  static TextStyle segmentControl = TextStyle(
    fontFamily: 'SFPro',
    fontSize: 13,
  );

  static Color segmentControlSelected(context) => activeColor(context);
  static Color segmentControlPressed(context) {
    Color baseColor = activeColor(context);
    return Color.fromARGB(
      128,
      baseColor.red,
      baseColor.green,
      baseColor.blue,
    );
  }

  static Color searchCursorColor = Color.fromARGB(255, 128, 128, 128);

  static const Color searchIconColor = Color.fromARGB(255, 128, 128, 128);
}
