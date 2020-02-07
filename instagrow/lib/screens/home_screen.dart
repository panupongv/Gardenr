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
  static const int TABS = 3;

  GlobalKey<NavigatorState> navigatorKey0 =
          GlobalKey<NavigatorState>(debugLabel: 'key0'),
      navigatorKey1 = GlobalKey<NavigatorState>(debugLabel: 'key1'),
      navigatorKey2 = GlobalKey<NavigatorState>(debugLabel: 'key2');

  HomeScreen(this.user);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: Styles.activeColor(context),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.home,
            ),
            title: Text("My Garden", style: Styles.tabTitle(context),),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CustomIcons.star,
            ),
            title: Text("Following", style: Styles.tabTitle(context),),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.person,
            ),
            title: Text("My Profile", style: Styles.tabTitle(context),),
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
            break;
          case 1:
            return CupertinoTabView(
              navigatorKey: navigatorKey1,
              builder: (BuildContext context) =>
                  DashBoardScreen(DashBoardContentType.Following),
            );
            break;
          case 2:
            return CupertinoTabView(
              navigatorKey: navigatorKey2,
              builder: (BuildContext context) => ProfileScreen(user),
            );
            break;
        }
        return null;
      },
    );
  }
}
