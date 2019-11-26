import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';
import 'package:instagrow/screens/home_screen.dart';
import 'package:instagrow/screens/signin_screen.dart';
import 'package:instagrow/utils/auth_service.dart';
import 'package:provider/provider.dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.error == null && snapshot.hasData) {
              return HomeScreen(snapshot.data);
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

  //@override
  Widget _build(BuildContext context) {
    return CupertinoApp(
      home: FutureBuilder<FirebaseUser>(
        future: Provider.of<AuthService>(context).getUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // log error to console                                            ⇐ NEW
            if (snapshot.error != null) {
              print("error");
              return Text(snapshot.error.toString());
            }
            // redirect to the proper page, pass the user into the
            // `HomePage` so we can display the user email in welcome msg     ⇐ NEW
            return snapshot.hasData
                ? HomeScreen(snapshot.data)
                : SignInScreen();
          } else {
            // show loading indicator                                         ⇐ NEW
            return Text("WAIT");
          }
        },
      ),
    );
  }
}
