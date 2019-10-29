import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';
import 'package:instagrow/screens/dashboard.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:instagrow/models/user_information.dart';

class HomeScreen extends StatelessWidget {
  String temp;
  @override
  Widget build(BuildContext context) {
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
              return DashBoard(
                  "My Garden",
                  FirebaseDatabase.instance
                      .reference()
                      .child('plants')
                      .orderByChild('ownerId')
                      .equalTo(UserInformation().userId));
              break;
            case 1:
              return DashBoard("Following", null);
              break;
          }
          return null;
        });
      },
    );
  }
}
