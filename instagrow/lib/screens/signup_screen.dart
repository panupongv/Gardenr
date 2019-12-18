import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/utils/auth_service.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/widgets/quick_dialog.dart';
import 'package:sprintf/sprintf.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String _email, _password, _confirmPassword;

  @override
  initState() {
    super.initState();
    _email = _password = _confirmPassword = "";
  }


  Future<void> signUp() async {
    bool hasEmptyField = _email == "" || _password == "";
    bool passwordMismatch = _password != _confirmPassword;
    bool passwordTooShort = _password.length < 6;

    if (hasEmptyField) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return getQuickAlertDialog(
              context,
              "Missing Field",
              "Please enter your " + (_email == "" ? "email" : "password"),
              "Dismiss");
        },
      );
    } else if (passwordMismatch) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return getQuickAlertDialog(context, "Passwords Mismatch",
                "Please make sure entered passwords are identical", "Dismiss");
          });
    } else if (passwordTooShort) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return getQuickAlertDialog(context, "Password Too Short",
                "The minimum length of password is 6 characters", "Dismiss");
          });
    } else {
      try {
        FirebaseUser user = await AuthService.signUp(_email, _password);
        DatabaseService.createUserInstance(user);

        showCupertinoDialog(
          context: context,
          builder: (context) {
            String _content = sprintf(
                "An email has been sent to %s. Please verify your email before attempting to login.",
                [_email]);
            return CupertinoAlertDialog(
              title: Text("Account Created"),
              content: Text(_content),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pop(context, _email);
                  },
                )
              ],
            );
          },
        );
      } catch (e) {
        print("Exception while signing up: " + e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CupertinoTextField(
              placeholder: "Email",
              onChanged: (currentText) {
                _email = currentText;
              },
            ),
            CupertinoTextField(
              placeholder: "Password",
              obscureText: true,
              onChanged: (currentText) {
                _password = currentText;
              },
            ),
            CupertinoTextField(
              placeholder: "Confirm Password",
              obscureText: true,
              onChanged: (currentText) {
                _confirmPassword = currentText;
              },
            ),
            CupertinoButton.filled(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: Text("Sign Up"),
              onPressed: signUp,
            ),
          ],
        ),
      ),
    );
  }
}
