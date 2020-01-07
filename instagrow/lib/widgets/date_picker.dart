import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DatePick extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoDatePicker(onDateTimeChanged: (DateTime value) {print(value);},);
    
  }

}