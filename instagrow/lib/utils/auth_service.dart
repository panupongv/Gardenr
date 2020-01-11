import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:tuple/tuple.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<FirebaseUser> getUser() {
    return _auth.currentUser();
  }

  static Future<Tuple2<FirebaseUser, String>> signIn(
      String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (!result.user.isEmailVerified) {
        throw PlatformException(
            code: '', message: "The account has not been verified.");
      }
      return Tuple2<FirebaseUser, String>(result.user, null);
    } on PlatformException catch (e) {
      return Tuple2<FirebaseUser, String>(null, e.message);
    }
  }

  static Future<Tuple2<FirebaseUser, String>> signUp(
      String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      user.sendEmailVerification();
      return Tuple2<FirebaseUser, String>(user, null);
    } on PlatformException catch (e) {
      return Tuple2<FirebaseUser, String>(null, e.message);
    }
  }

  static Future<void> logOut() async {
    await _auth.signOut();
  }
}
