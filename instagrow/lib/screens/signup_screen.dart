import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/auth_field_validator.dart';
import 'package:instagrow/services/auth_service.dart';
import 'package:instagrow/services/database_service.dart';
import 'package:instagrow/utils/style.dart';
import 'package:instagrow/widgets/quick_dialog.dart';
import 'package:instagrow/widgets/text_field_separator.dart';
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

    if (hasEmptyField) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return quickAlertDialog(
            context,
            "Missing Field",
            "Please enter your " + (email == "" ? "email" : "password"),
            "Dismiss",
          );
        },
      );
    } else if (passwordMismatch) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return quickAlertDialog(
            context,
            "Passwords Mismatch",
            "Please make sure entered passwords are identical",
            "Dismiss",
          );
        },
      );
    } else {
      Tuple2<FirebaseUser, String> signUpResult =
          await AuthService.signUp(email, password);

      if (signUpResult.item1 != null) {
        DatabaseService.createUserInstance(signUpResult.item1);
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            String _content = sprintf(
                "An email has been sent to %s. Please verify your email before attempting to login.",
                [email]);
            return CupertinoAlertDialog(
              title: Text(
                "Account Created",
                style: Styles.dialogTitle(context),
              ),
              content: Text(
                _content,
                style: Styles.dialogContent(context),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(
                    "OK",
                    style: Styles.dialogActionNormal(context),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(email);
                  },
                ),
              ],
            );
          },
        );
      } else {
        String message = signUpResult.item2;
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return quickAlertDialog(
              context,
              "Authentication Error",
              message,
              "Dismiss",
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
              height: 1,
              color: Styles.separatorLine(context),
            ),
            CupertinoTextField(
              
              placeholder: "Email",
              keyboardType: TextInputType.emailAddress,
              decoration: Styles.textFieldDecoration(context),
              controller: _emailController,
            ),
            TextFieldSeparator(
              0.95,
              Colors.transparent,
              Styles.separatorLine(context),
            ),
            CupertinoTextField(
              placeholder: "Password",
              decoration: Styles.textFieldDecoration(context),
              controller: _passwordController,
              obscureText: true,
            ),
            TextFieldSeparator(
              0.95,
              Colors.transparent,
              Styles.separatorLine(context),
            ),
            CupertinoTextField(
              placeholder: "Confirm Password",
              decoration: Styles.textFieldDecoration(context),
              controller: _confirmPasswordController,
              obscureText: true,
            ),
            Container(
              height: 1,
              color: Styles.separatorLine(context),
            ),
            Container(
              height: 24,
            ),
            UnconstrainedBox(
              child: CupertinoButton.filled(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: Text("Sign Up"),
                onPressed: signUp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
