import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/dashboard_plant.dart';
import 'package:instagrow/screens/plant_info_screen.dart';

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
              left: 0,
              right: 0,
            ),
            child: Container(
              height: 1,
              color: CupertinoColors.lightBackgroundGray,
            ),
          ),
        ],
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return PlantInfoScreen(plant);
        }));
      },
      child: Container(child: listItem,),
    );
  }
}
