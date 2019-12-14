import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/dashboard_plant.dart';

class PlantInfoBoard extends StatelessWidget {
  DashBoardPlant plant;

  PlantInfoBoard(this.plant);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(plant.name),
        trailing: Text("Edit"),
      ),
      child: Container(
        color: Colors.white,
      ),
    );
  }
}
