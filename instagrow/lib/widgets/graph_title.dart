import 'package:flutter/cupertino.dart';

class GraphTitle extends StatelessWidget {
  final String title;
  final Function iconTapCallBack;

  GraphTitle(this.title, this.iconTapCallBack);

  @override
  Widget build(BuildContext context) {
    EdgeInsets insets = EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: insets,
          child: Text(title),
        ),
        Padding(
          padding: insets,
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
