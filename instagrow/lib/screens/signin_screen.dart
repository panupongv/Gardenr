import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagrow/utils/auth_field_validator.dart';
import 'package:instagrow/screens/home_screen.dart';
import 'package:instagrow/screens/signup_screen.dart';
import 'package:instagrow/services/auth_service.dart';
import 'package:instagrow/utils/size_config.dart';
import 'package:instagrow/utils/style.dart';
import 'package:instagrow/widgets/quick_dialog.dart';
import 'package:instagrow/widgets/text_field_separator.dart';
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
          return quickAlertDialog(
            context,
            "Missing Field",
            "Please enter your " + (email == "" ? "email" : "password"),
            "Dismiss",
          );
        },
      );
    } else {
      Tuple2<FirebaseUser, String> signInResult =
          await AuthService.signIn(email, password);

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
            return quickAlertDialog(
                context, "Authentication Error", message, "Dismiss");
          },
        );
      }
    }
  }

  Widget _appLogo() {
    bool darkThemed = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return Center(
      child: Container(
        width: PROFILE_TAB_IMAGE_SIZE,
        height: PROFILE_TAB_IMAGE_SIZE,
        child: Image(
          image: AssetImage(darkThemed
              ? 'assets/images/logo_dark.png'
              : 'assets/images/logo_light.png'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            _appLogo(),
            Container(height: 16),
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
                child: Text("Sign In"),
                onPressed: signIn,
              ),
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
