import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<FirebaseUser> getUser() {
    return _auth.currentUser();
  }

  static Future<FirebaseUser> signIn(String email, String password) async {
    try {
      AuthResult result = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      throw new AuthException(e.code, e.message);
    }
  }

  static Future<FirebaseUser> signUp(String email, String password) async {
    AuthResult result = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);
    FirebaseUser user = result.user;
    user.sendEmailVerification();
    return user;
  }

  static Future<void> logOut() async {
    await _auth.signOut();
  }
}
