import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/utils/style.dart';

class GraphFocusScreen extends StatelessWidget {
  final Widget graph;

  GraphFocusScreen(this.graph);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RotatedBox(
        quarterTurns: 1,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            actionsForegroundColor: Styles.activeColor(context),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: graph,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
