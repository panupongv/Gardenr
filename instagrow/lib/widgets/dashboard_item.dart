import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/screens/plant_profile_screen.dart';

class DashBoardItem extends StatelessWidget {
  final int index;
  final Plant plant;
  final bool isMyPlant, lastItem;

  DashBoardItem({this.index, this.plant, this.isMyPlant, this.lastItem});

  @override
  Widget build(BuildContext context) {
    final Container defaultImage = Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/defaultplant.png')), color: CupertinoColors.inactiveGray),
    );

    final SafeArea item = SafeArea(
      top: false,
      bottom: false,
      minimum: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(38),
            child: CachedNetworkImage(
              imageUrl: plant.imageUrl,
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
          return PlantProfileScreen(plant, isMyPlant);
        }));
      },
      child: Container(
        child: listItem,
      ),
    );
  }
}
