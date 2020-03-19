import 'dart:async';
import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/utils/enums.dart';
import 'package:instagrow/models/user_profile.dart';
import 'package:instagrow/screens/profile_edit_screen.dart';
import 'package:instagrow/screens/signin_screen.dart';
import 'package:instagrow/services/auth_service.dart';
import 'package:instagrow/services/database_service.dart';
import 'package:instagrow/utils/size_config.dart';
import 'package:instagrow/utils/style.dart';
import 'package:instagrow/widgets/circular_cached_image.dart';
import 'package:instagrow/widgets/default_images.dart';
import 'package:instagrow/widgets/description_expandable.dart';
import 'package:page_transition/page_transition.dart';

class ProfileScreen extends StatefulWidget {
  final FirebaseUser user;

  ProfileScreen(this.user);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userId;
  UserProfile _myProfile;

  CircularCachedImage _imageDisplay;

  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _userId = widget.user.uid;
    _myProfile = UserProfile(widget.user.uid, "", "", "");
    _streamSubscription = DatabaseService.userProfileStream(widget.user).listen(
      (Event event) {
        if (event != null &&
            event.snapshot != null &&
            event.snapshot.value != null) {
          LinkedHashMap userData = event.snapshot.value;
          setState(() {
            if (userData != null) {
              _myProfile =
                  UserProfile.fromQueryData(_userId, event.snapshot.value);
            }
          });
        }
      },
    );

    super.initState();
  }

  Future<void> _showOptionsDialog() async {
    int selectedOption = 0;
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text(
                "Edit Profile",
                style: Styles.actionSheetAction(context),
              ),
              onPressed: () {
                selectedOption = 1;
                Navigator.of(context).pop();
              },
            ),
            CupertinoActionSheetAction(
              child: Text(
                "Logout",
                style: Styles.actionSheetActionRed(context),
              ),
              onPressed: () {
                selectedOption = 2;
                Navigator.of(context).pop();
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text("Cancel", style: Styles.actionSheetAction(context)),
            onPressed: Navigator.of(context).pop,
          ),
        );
      },
    );

    if (selectedOption == 0) {
      return;
    }

    switch (selectedOption) {
      case 1:
        _openEditScreen();
        break;
      case 2:
        _logOut();
        break;
    }
  }

  Future<void> _logOut() async {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            "Logout",
            style: Styles.dialogTitle(context),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: Styles.dialogContent(context),
          ),
          actions: <Widget>[
            CupertinoButton(
              child: Text(
                "Cancel",
                style: Styles.dialogActionNormal(context),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoButton(
              child: Text(
                "Logout",
                style: Styles.dialogActionCrucial(context),
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

  Future<void> _openEditScreen() async {
    Navigator.of(context).push(
      PageTransition(
        type: PageTransitionType.fade,
        child: ProfileEditScreen(
          _imageDisplay.imageProvider,
          _myProfile.name,
          _myProfile.description,
          PreviousScreen.UserProfile,
          null,
          null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _imageDisplay = CircularCachedImage(
        _myProfile.imageUrl,
        PROFILE_TAB_IMAGE_SIZE,
        progressIndicator(context),
        defaultUserImage(context));

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      navigationBar: CupertinoNavigationBar(
        actionsForegroundColor: Styles.activeColor(context),
        border: null,
        middle: Text(
          "Profile",
          style: Styles.navigationBarTitle(context),
        ),
        trailing: GestureDetector(
          child: Icon(CupertinoIcons.ellipsis),
          onTap: _showOptionsDialog,
        ),
      ),
      child: SafeArea(
        top: true,
        child: ListView(
          children: <Widget>[
            UnconstrainedBox(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: _imageDisplay,
              ),
            ),
            Container(
              child: Text(
                _myProfile.name,
                textAlign: TextAlign.center,
                style: Styles.plantProfileName(context),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 12,
                top: 32,
                bottom: 8,
              ),
              child: Text(
                (_myProfile.description != null && _myProfile.description != "")
                    ? "Description"
                    : "",
                style: Styles.aboutUser(context),
              ),
            ),
            DescriptionExpandable(_myProfile.description),
            Container(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
