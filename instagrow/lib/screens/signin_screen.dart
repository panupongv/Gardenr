import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/screens/home_screen.dart';
import 'package:instagrow/screens/signup_screen.dart';
import 'package:instagrow/utils/auth_service.dart';
import 'package:instagrow/widgets/quick_dialog.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String _email, _password;
  TextEditingController _emailController, _passwordController;

  @override
  initState() {
    super.initState();
    _email = _password = "";
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  Future<void> navigateToSignUpScreen() async {
    Route route = CupertinoPageRoute(builder: (context) => SignUpScreen());
    String newEmail = (await Navigator.push(context, route)) as String;
    _email = _emailController.text = newEmail;
    _password = _passwordController.text = "";
  }

  Future<void> signIn() async {
    bool hasEmptyField = _email == "" || _password == "";

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
    } else {
      try {
        FirebaseUser user = await AuthService.signIn(_email, _password);
        if (!user.isEmailVerified) {
          throw Exception("NOT_VERIFIED");
        }
        Route route =
            CupertinoPageRoute(builder: (context) => HomeScreen(user));
        Navigator.pushReplacement(context, route);
      } catch (e) {
        print("Exception while Logging in: " + e.message);
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
              onChanged: (currentText) {
                _email = currentText;
              },
            ),
            CupertinoTextField(
              controller: _passwordController,
              placeholder: "Password",
              obscureText: true,
              onChanged: (currentText) {
                _password = currentText;
              },
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
