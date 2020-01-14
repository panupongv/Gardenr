import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/screens/profile_edit_screen.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/utils/size_config.dart';
import 'package:instagrow/utils/style.dart';
import 'package:instagrow/widgets/circular_cached_image.dart';
import 'package:instagrow/widgets/default_images.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';
import 'package:page_transition/page_transition.dart';

class ProfileScreen extends StatefulWidget {
  final FirebaseUser user;

  ProfileScreen(this.user);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userImageUrl, _userDisplayName, _userDescription;

  CircularCachedImage _imageDisplay;

  Future<void> _openEditScreen() async {
    Navigator.of(context).push(PageTransition(
        type: PageTransitionType.fade,
        child: ProfileEditScreen(_imageDisplay.imageProvider, _userDisplayName,
            _userDescription, PreviousScreen.UserProfile, null, null)));
  }

  @override
  void initState() {
    _userImageUrl = _userDisplayName = _userDescription = "";

    DatabaseService.userProfileStream(widget.user).listen((Event event) {
      if (event != null &&
          event.snapshot != null &&
          event.snapshot.value != null) {
        LinkedHashMap userData = event.snapshot.value;
        setState(() {
          _userImageUrl = userData['imageUrl'] ?? _userImageUrl;
          _userDisplayName = userData['name'] ?? _userDisplayName;
          _userDescription = userData['description'] ?? _userDescription;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _imageDisplay = CircularCachedImage(
        _userImageUrl, PROFILE_IMAGE_SIZE, progressIndicator(context), defaultUserImage(context));

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      navigationBar: CupertinoNavigationBar(
        border: null,
        trailing: navigationBarTextButton(
          "Edit",
          _openEditScreen,
        ),
      ),
      child: SafeArea(
        top: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            UnconstrainedBox(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: _imageDisplay,
              ),
            ),
            Container(
              color: Colors.pink,
              child: Text(_userDisplayName),
            ),
            Container(
              color: Colors.amberAccent,
              child: Text(_userDescription),
            ),
          ],
        ),
      ),
    );
  }
}
