import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/dashboard_plant.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';

class PlantInfoScreen extends StatelessWidget {
  final DashBoardPlant plant;

  PlantInfoScreen(this.plant);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: navigationBarTitle(plant.name),
        trailing: Text("Edit"),
      ),
      child: Container(
        color: Colors.white,
      ),
    );
  }
}
