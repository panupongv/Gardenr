import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagrow/models/auth_field_validator.dart';
import 'package:instagrow/screens/home_screen.dart';
import 'package:instagrow/screens/signup_screen.dart';
import 'package:instagrow/utils/auth_service.dart';
import 'package:instagrow/widgets/quick_dialog.dart';
import 'package:tuple/tuple.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _emailController, _passwordController;

  @override
  initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  Future<void> navigateToSignUpScreen() async {
    Route route = CupertinoPageRoute(builder: (context) => SignUpScreen());
    String newEmail = (await Navigator.push(context, route)) as String;
    _emailController.text = newEmail;
    _passwordController.text = "";
  }

  Future<void> signIn() async {
    String email = _emailController.text, password = _passwordController.text;
    bool hasEmptyField = AuthFieldValidator.hasEmptyField([email, password]);

    if (hasEmptyField) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return getQuickAlertDialog(
              context,
              "Missing Field",
              "Please enter your " + (email == "" ? "email" : "password"),
              "Dismiss");
        },
      );
    } else {
      Tuple2<FirebaseUser, String> signInResult = await AuthService.signIn(email, password);

      if (signInResult.item1 != null) {
        FirebaseUser user = signInResult.item1;
        Route route =
            CupertinoPageRoute(builder: (context) => HomeScreen(user));
        Navigator.pushReplacement(context, route);
      } else {
        String message = signInResult.item2;
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return getQuickAlertDialog(context, "Authentication Error", message, "Dismiss");
          }
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
            CupertinoButton.filled(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: Text("Sign In"),
              onPressed: signIn,
            ),
            CupertinoButton(
              child: Text("Create an account"),
              onPressed: navigateToSignUpScreen,
            )
          ],
        ),
      ),
    );
  }
}
