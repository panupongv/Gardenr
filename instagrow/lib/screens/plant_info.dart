import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlantInfo extends StatefulWidget {

  PlantInfo();

  @override
  _PlantInfoState createState() => _PlantInfoState();
}

class _PlantInfoState extends State<PlantInfo> {
  String name;
  String type;
  String description;

  Widget build(BuildContext context) {
    return Text(name + " " + type);
  }
}
