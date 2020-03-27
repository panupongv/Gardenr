import 'package:flutter/material.dart';
import 'package:instagrow/utils/style.dart';

class DatePickerArrow extends StatelessWidget {
  final IconData _iconData;
  final int _currentIndex;
  final int _lowerIndexBound, _upperIndexBound;
  final Function _onTapCallBack;

  DatePickerArrow(this._iconData, this._currentIndex, this._lowerIndexBound,
      this._upperIndexBound, this._onTapCallBack);

  Widget build(BuildContext context) {
    int lowerIndexBound =
        (_lowerIndexBound == null) ? -100 : _lowerIndexBound;
    int upperIndexBound =
        (_upperIndexBound == null) ? 100 : _upperIndexBound;

    bool active = _currentIndex > lowerIndexBound &&
        _currentIndex < upperIndexBound;

    return GestureDetector(
      child: Icon(
        _iconData,
        size: 32,
        color:
            active ? Styles.activeColor(context) : Styles.dynamicGray(context),
      ),
      onTap: () {if (active) _onTapCallBack();},
    );
  }
}
