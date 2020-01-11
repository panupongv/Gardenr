import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagrow/models/auth_field_validator.dart';
import 'package:instagrow/utils/auth_service.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/widgets/quick_dialog.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tuple/tuple.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _emailController,
      _passwordController,
      _confirmPasswordController;

  @override
  initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  Future<void> signUp() async {
    String email = _emailController.text,
        password = _passwordController.text,
        confirmPassword = _confirmPasswordController.text;

    bool hasEmptyField =
        AuthFieldValidator.hasEmptyField([email, password, confirmPassword]);
    bool passwordMismatch =
        AuthFieldValidator.passwordMismatch(password, confirmPassword);
    bool passwordTooShort = AuthFieldValidator.passwordTooShort(password);

    if (hasEmptyField) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return getQuickAlertDialog(
              context,
              "Missing Field",
              "Please enter your " + (email == "" ? "email" : "password"),
              "Dismiss");
        },
      );
    } else if (passwordMismatch) {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return getQuickAlertDialog(context, "Passwords Mismatch",
                "Please make sure entered passwords are identical", "Dismiss");
          });
    } else if (passwordTooShort) {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return getQuickAlertDialog(context, "Password Too Short",
                "The minimum length of password is 6 characters", "Dismiss");
          });
    } else {
      Tuple2<FirebaseUser, String> signUpResult =
          await AuthService.signUp(email, password);

      if (signUpResult.item1 != null) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            String _content = sprintf(
                "An email has been sent to %s. Please verify your email before attempting to login.",
                [email]);
            return CupertinoAlertDialog(
              title: Text("Account Created"),
              content: Text(_content),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(email);
                  },
                )
              ],
            );
          },
        );
      } else {
        String message = signUpResult.item2;
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return getQuickAlertDialog(
                context, "Authentication Error", message, "Dismiss");
          },
        );
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
              controller: _emailController,
              placeholder: "Email",
            ),
            CupertinoTextField(
              controller: _passwordController,
              placeholder: "Password",
              obscureText: true,
            ),
            CupertinoTextField(
              controller: _confirmPasswordController,
              placeholder: "Confirm Password",
              obscureText: true,
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
