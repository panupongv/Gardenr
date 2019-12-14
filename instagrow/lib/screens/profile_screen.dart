import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: navigationBarText("Profile"),
      ),
      child: Container(),
    );
  }
}
