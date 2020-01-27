import 'package:flutter/cupertino.dart';

class GraphTitle extends StatelessWidget {
  final String title;
  final Function iconTapCallBack;

  GraphTitle(this.title, this.iconTapCallBack);

  @override
  Widget build(BuildContext context) {
    EdgeInsets textPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        iconPadding = EdgeInsets.only(right: 12);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: textPadding,
          child: Text(title),
        ),
        Padding(
          padding: iconPadding,
          child: GestureDetector(
            child: Icon(
              CupertinoIcons.fullscreen,
            ),
            onTap: iconTapCallBack,
          ),
        ),
      ],
    );
  }
}
