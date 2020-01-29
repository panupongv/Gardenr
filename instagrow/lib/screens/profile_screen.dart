import 'dart:async';
import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/enums.dart';
import 'package:instagrow/models/user_profile.dart';
import 'package:instagrow/screens/profile_edit_screen.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/utils/size_config.dart';
import 'package:instagrow/utils/style.dart';
import 'package:instagrow/widgets/circular_cached_image.dart';
import 'package:instagrow/widgets/default_images.dart';
import 'package:instagrow/widgets/description_expandable.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';
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

  Future<void> _openEditScreen() async {
    Navigator.of(context).push(PageTransition(
        type: PageTransitionType.fade,
        child: ProfileEditScreen(_imageDisplay.imageProvider, _myProfile.name,
            _myProfile.description, PreviousScreen.UserProfile, null, null)));
  }

  @override
  void initState() {
    _userId = widget.user.uid;
    _myProfile = UserProfile(widget.user.uid, "", "", "");
    _streamSubscription = DatabaseService.userProfileStream(widget.user).listen((Event event) {
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
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _imageDisplay = CircularCachedImage(_myProfile.imageUrl, PROFILE_TAB_IMAGE_SIZE,
        progressIndicator(context), defaultUserImage(context));

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      navigationBar: CupertinoNavigationBar(
        actionsForegroundColor: Styles.activeColor(context),
        border: null,
        trailing: navigationBarTextButton(
          context, 
          "Edit",
          _openEditScreen,
        ),
      ),
      child: SafeArea(
        top: true,
        child: SingleChildScrollView(
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
                child: Text(
                  _myProfile.name,
                  textAlign: TextAlign.center,
                  style: Styles.plantProfileName(context),
                ),
              ),
              Container(
                height: 16,
              ),
              DescriptionExpandable(_myProfile.description),
              Container(height: 32,)
            ],
          ),
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
