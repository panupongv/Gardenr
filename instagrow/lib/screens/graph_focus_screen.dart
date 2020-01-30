import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/utils/style.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';
import 'package:zoom_widget/zoom_widget.dart';

class GraphFocusScreen extends StatelessWidget {
  final Widget _focusedGraph;

  GraphFocusScreen(this._focusedGraph);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RotatedBox(
        quarterTurns: 1,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: navigationBarTextButton(
              context,
              "Close",
              () {
                Navigator.of(context).pop();
              },
            ),
            actionsForegroundColor: Styles.activeColor(context),
          ),
          child: _focusedGraph,
        ),
      ),
    );
  }
}
