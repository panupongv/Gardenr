import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';
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
    Trace trace = FirebasePerformance.instance.newTrace('Sign In');
    trace.start();
    Tuple2 signInResult;
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (!result.user.isEmailVerified) {
        throw PlatformException(
            code: '', message: "The account has not been verified.");
      }
      signInResult = Tuple2<FirebaseUser, String>(result.user, null);
    } on PlatformException catch (e) {
      signInResult = Tuple2<FirebaseUser, String>(null, e.message);
    }
    trace.stop();
    return signInResult;
  }

  static Future<Tuple2<FirebaseUser, String>> signUp(
      String email, String password) async {
    Trace trace = FirebasePerformance.instance.newTrace('Sign Up');
    trace.start();
    Tuple2<FirebaseUser, String> signUpResult;
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      user.sendEmailVerification();
      logOut();
      signUpResult = Tuple2(user, null);
    } on PlatformException catch (e) {
      signUpResult = Tuple2(null, e.message);
    }
    trace.stop();
    return signUpResult;
  }

  static Future<void> logOut() async {
    await _auth.signOut();
  }
}
