import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/utils/style.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';

class GraphFocusPopup extends StatelessWidget {
  final String _title;
  final Widget _focusedGraph;

  GraphFocusPopup(this._title, this._focusedGraph);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RotatedBox(
        quarterTurns: 1,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: GestureDetector(
              child: Icon(CupertinoIcons.clear_thick),
              onTap: Navigator.of(context).pop,
            ),
            middle: Text(
              _title,
              style: Styles.navigationBarTitle(context),
            ),
            actionsForegroundColor: Styles.activeColor(context),
          ),
          child: SafeArea(
            child: _focusedGraph,
          ),
        ),
      ),
    );
  }
}
