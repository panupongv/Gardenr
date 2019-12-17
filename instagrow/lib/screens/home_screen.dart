import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';
import 'package:instagrow/screens/dashboard_screen.dart';
import 'package:instagrow/screens/profile_screen.dart';
import 'package:instagrow/screens/setting_screen.dart';
import 'package:instagrow/utils/database_service.dart';

class HomeScreen extends StatelessWidget {
  FirebaseUser user;

  HomeScreen(this.user);

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
            icon: Icon(CupertinoIcons.person),
            title: Text("My Profile"),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear),
            title: Text("Setting"),
          ),
        ],
      ),
      tabBuilder: (context, i) {
        return CupertinoTabView(
          builder: (context) {
            switch (i) {
              case 0:
                return DashBoardScreen(
                  "My Garden",
                  DatabaseService.getMyPlants,
                );
                break;
              case 1:
                return DashBoardScreen(
                  "Following",
                  DatabaseService.getFollowingPlants,
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
