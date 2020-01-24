import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';
import 'package:instagrow/screens/home_screen.dart';
import 'package:instagrow/screens/signin_screen.dart';
import 'package:instagrow/utils/auth_service.dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoTheme.of(context),
      home: FutureBuilder<FirebaseUser>(
        future: AuthService.getUser(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.error == null && snapshot.hasData && snapshot.data != null) {
              FirebaseUser user = snapshot.data;
              // if (user.displayName)
              print("Continue as ${user.uid}");
              return HomeScreen(user);
            } else {
              return SignInScreen();
            }
          } else {
            return Text("WAIT");
          }
        },
      ),
    );
  }
}
