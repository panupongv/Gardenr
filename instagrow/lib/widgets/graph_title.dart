import 'package:flutter/cupertino.dart';
import 'package:instagrow/utils/style.dart';

class GraphTitle extends StatelessWidget {
  final String _title;
  final Function _iconTapCallBack;

  GraphTitle(this._title, this._iconTapCallBack);

  @override
  Widget build(BuildContext context) {
    EdgeInsets textPadding = EdgeInsets.only(left: 12, top: 8),
        iconPadding = EdgeInsets.only(right: 12);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: textPadding,
          child: Text(
            _title,
            style: Styles.graphTitle(context),
          ),
        ),
        Padding(
          padding: iconPadding,
          child: GestureDetector(
            child: Icon(
              CupertinoIcons.fullscreen,
              color: Styles.activeColor(context),
            ),
            onTap: _iconTapCallBack,
          ),
        ),
      ],
    );
  }
}
