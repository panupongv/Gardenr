import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';
import 'package:instagrow/models/enums.dart';
import 'package:instagrow/screens/dashboard_screen.dart';
import 'package:instagrow/screens/profile_screen.dart';
import 'package:instagrow/utils/style.dart';
import 'package:instagrow/widgets/custom_icons.dart';

class HomeScreen extends StatelessWidget {
  int _currentIndex = 0;
  final FirebaseUser user;
  static const int TABS = 4;

  GlobalKey<NavigatorState> navigatorKey0 = GlobalKey<NavigatorState>(),
      navigatorKey1 = GlobalKey<NavigatorState>(),
      navigatorKey2 = GlobalKey<NavigatorState>();
  // navigatorKey3 = GlobalKey<NavigatorState>();

  HomeScreen(this.user);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.home,
            ),
            activeIcon: Icon(
              CupertinoIcons.home,
              color: Styles.activeColor(context),
            ),
            title: Text("My Garden"),
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.star),
            activeIcon: Icon(
              CustomIcons.star,
              color: Styles.activeColor(context),
            ),
            title: Text("Following"),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            activeIcon: Icon(
              CupertinoIcons.person,
              color: Styles.activeColor(context),
            ),
            title: Text("My Profile"),
          ),
        ],
        onTap: (int index) {
          if (_currentIndex == index) {
            switch (index) {
              case 0:
                navigatorKey0.currentState.popUntil((Route r) => r.isFirst);
                break;
              case 1:
                navigatorKey1.currentState.popUntil((Route r) => r.isFirst);
                break;
              case 2:
                navigatorKey2.currentState.popUntil((Route r) => r.isFirst);
                break;
            }
          }
          _currentIndex = index;
        },
      ),
      tabBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              navigatorKey: navigatorKey0,
              builder: (BuildContext context) =>
                  DashBoardScreen(DashBoardContentType.Garden),
            );
          case 1:
            return CupertinoTabView(
              navigatorKey: navigatorKey1,
              builder: (BuildContext context) =>
                  DashBoardScreen(DashBoardContentType.Following),
            );
          case 2:
            return CupertinoTabView(
              navigatorKey: navigatorKey2,
              builder: (BuildContext context) => ProfileScreen(user),
            );
        }
        return null;
      },
    );
  }
}
