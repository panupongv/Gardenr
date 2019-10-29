import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';
import 'package:instagrow/screens/home_screen.dart';
import 'package:firebase_database/firebase_database.dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(home: HomeScreen());
  }
}

class FirebaseTestHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var query = FirebaseDatabase.instance.reference().child('users');

    StreamBuilder builder = StreamBuilder(
      stream: query.onValue,
      builder: (context, snap) {
        if (!snap.hasData || snap.hasError) {
          return CircularProgressIndicator();
        }
        DataSnapshot snapshot = snap.data.snapshot;
        return Text(
          "xxx" + snapshot.value.toString(),
          style: TextStyle(color: Colors.red),
        );
      },
    );

    return Scaffold(
      body: Center(
        child: builder,
      ),
    );
  }
}
