import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';
import 'package:instagrow/screens/dashboard_screen.dart';
import 'package:instagrow/screens/profile_screen.dart';
import 'package:instagrow/screens/setting_screen.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/widgets/custom_icons.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseUser user;

  HomeScreen(this.user);

  @override
  Widget build(BuildContext context) {


    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            // title: Text("My Garden"),
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.star),
            // title: Text("Following"),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            // title: Text("My Profile"),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear),
            // title: Text("Setting"),
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return DashBoardScreen(
                  DashBoardContentType.MyPlants,
                );
                break;
              case 1:
                return DashBoardScreen(
                  DashBoardContentType.Following,
                );
                break;
              case 2:
                return ProfileScreen(user);
                break;
              case 3:
                return SettingScreen();
                break;
            }
            return null;
          },
        );
      },
    );
  }
}
