import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';
import 'package:instagrow/screens/home_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'utils/private.dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(home: HomeScreen());
  }
}
