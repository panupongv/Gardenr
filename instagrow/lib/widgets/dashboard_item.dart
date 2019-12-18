import 'package:cached_network_image/cached_network_image.dart';
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
    final Container defaultImage = Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(color: Colors.amber),
    );

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
            child: CachedNetworkImage(
              imageUrl: "https://picsum.photos/78",
              imageBuilder: (BuildContext context, ImageProvider imageProvider) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  width: 78,
                  height: 78,
                );
              },
              placeholder: (context, url) => defaultImage,
              errorWidget: (context, url, error) => defaultImage,
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
                      Text(plant.name, style: Theme.of(context).textTheme.title.merge(TextStyle(color: Colors.red)),),
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
      child: Container(
        child: listItem,
      ),
    );
  }
}
