import 'package:flutter/cupertino.dart';

class TextFieldSeparator extends StatelessWidget {
  final double _filledRatio;
  final Color _edgesColor, _middleColor;

  const TextFieldSeparator(
      this._filledRatio, this._edgesColor, this._middleColor);

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;
    double middleWidth = maxWidth * _filledRatio;
    double edgesWidth = maxWidth * (1 - _filledRatio) / 2;
    return Container(
      height: 1,
      child: Row(
        children: <Widget>[
          Container(
            width: edgesWidth,
            color: _edgesColor,
          ),
          Container(
            width: middleWidth,
            color: _middleColor,
          ),
          Container(
            width: edgesWidth,
            color: _edgesColor,
          ),
        ],
      ),
    );
  }
}
