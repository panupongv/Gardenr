import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/screens/signin_screen.dart';
import 'package:instagrow/utils/auth_service.dart';
import 'package:instagrow/widgets/search_bar.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with SingleTickerProviderStateMixin {
  bool showSearch;

  TextEditingController _searchTextController = new TextEditingController();
  FocusNode _searchFocusNode = new FocusNode();
  Animation _animation;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    showSearch = false;

    _animationController = new AnimationController(
      duration: new Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = new CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
    _searchFocusNode.addListener(() {
      if (!_animationController.isAnimating) {
        _animationController.forward();
      }
    });
  }

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

  void _cancelSearch() {
    _searchTextController.clear();
    _searchFocusNode.unfocus();
    _animationController.reverse();
    setState(() {
      showSearch = false;
    });
  }

  void _clearSearch() {
    _searchTextController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: showSearch? null:GestureDetector(
          child: Icon(
            CupertinoIcons.search,
          ),
          onTap: () {
            setState(() {
              showSearch = true;
            });
          },
        ),
        // middle: navigationBarTitle("Setting"),
        middle: showSearch
            ? IOSSearchBar(
                controller: _searchTextController,
                focusNode: _searchFocusNode,
                animation: _animation,
                onCancel: _cancelSearch,
                onClear: _clearSearch,
                onUpdate: (String x) {
                  print(x);
                },
              )
            : Text("Setting"),
            trailing: showSearch? null:Text("yoooo"),
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
