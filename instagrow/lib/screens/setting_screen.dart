import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/screens/signin_screen.dart';
import 'package:instagrow/utils/auth_service.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';

class SettingScreen extends StatelessWidget {
  Future<void> logOut(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: <Widget>[
            CupertinoButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoButton(
              child: Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await AuthService.logOut().then(
                  (_) {
                    Navigator.of(context).pop();
                    Route route = CupertinoPageRoute(
                        builder: (context) => SignInScreen());
                    Navigator.pushReplacement(context, route);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: navigationBarText("Setting"),
      ),
      child: DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CupertinoButton(
                child: Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  logOut(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
