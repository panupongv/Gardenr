import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/dashboard_plant.dart';
import 'package:instagrow/screens/plant_info_board.dart';

class DashBoardItem extends StatelessWidget {
  final int index;
  final DashBoardPlant plant;
  final bool lastItem;

  DashBoardItem({this.index, this.plant, this.lastItem});

  @override
  Widget build(BuildContext context) {
    final SafeArea item = SafeArea(
      top: false,
      bottom: false,
      minimum: const EdgeInsets.only(
        left: 8,
        top: 8,
        bottom: 8,
        right: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(38),
            child: Image.network(
              "https://picsum.photos/78",
              fit: BoxFit.cover,
              width: 76,
              height: 76,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(plant.name),
                      Text(plant.timeOffset)
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(plant.moisture.toString() + "   "),
                      Text(plant.temperature.toString())
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Widget listItem;

    if (lastItem) {
      listItem = item;
    } else {
      listItem = Column(
        children: <Widget>[
          item,
          Padding(
            padding: const EdgeInsets.only(
              left: 100,
              right: 16,
            ),
            child: Container(
              height: 1,
              color: CupertinoColors.inactiveGray,
            ),
          ),
        ],
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return PlantInfoBoard(plant);
        }));
      },
      child: Container(child: listItem,),
    );
  }

  @override
  Widget build2(BuildContext context) {
    Container item = Container(
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
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return PlantInfoBoard(plant);
        }));
      },
      child: item,
    );
  }
}
