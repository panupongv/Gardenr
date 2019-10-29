import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/dashboard_plant.dart';

class DashBoardItem extends StatelessWidget {
  final int index;
  final DashBoardPlant plant;
  bool lastItem;

  DashBoardItem({this.index, this.plant, this.lastItem});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text(plant.timeUpdated.toString())],
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
  }
}
