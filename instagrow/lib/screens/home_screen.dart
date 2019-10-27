import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';
import 'package:instagrow/screens/dashboard.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatelessWidget {
  String temp;
  @override
  Widget build(BuildContext context) {
    var value = FirebaseDatabase.instance.reference().child('gardenr-ed17f');
    StreamBuilder(
        stream: value.onValue,
        builder: (context, snap) {
          if (snap.hasData &&
              !snap.hasError &&
              snap.data.snapshot.value != null) {
            temp = snap.data.snapshot.value.toString();
          }
        });

//taking the data snapshot.
    
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.brightness),
            title: Text("My Garden"),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group),
            title: Text("Following"),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear),
            title: Text("Setting"),
          ),
        ],
      ),
      tabBuilder: (context, i) {
        return CupertinoTabView(builder: (context) {
          switch (i) {
            case 0:
              return DashBoard(temp);
              break;
            case 1:
              return DashBoard("Following");
              break;
          }
          return null;
        });
      },
    );
  }
}
