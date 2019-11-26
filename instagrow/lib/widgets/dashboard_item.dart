import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/dashboard_plant.dart';
import 'package:instagrow/screens/plant_info_board.dart';

class DashBoardItem extends StatelessWidget {
  final int index;
  final DashBoardPlant plant;
  bool lastItem;

  DashBoardItem({this.index, this.plant, this.lastItem});

  @override
  Widget build(BuildContext context) {
    Container item = Container(
      decoration: BoxDecoration(color: CupertinoColors.inactiveGray),
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(plant.name), 
              Text(plant.timeOffset),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Moisture: " + plant.moisture.toString()),
              Text("Temperature: " + plant.temperature.toString())
            ],
          )
        ],
      ),
    );
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) {
            return PlantInfoBoard(plant);
          }
        ));
      },
      child: item,
    );
  }
}
