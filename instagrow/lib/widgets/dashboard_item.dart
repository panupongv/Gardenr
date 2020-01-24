import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/utils/size_config.dart';
import 'package:instagrow/utils/style.dart';
import 'package:instagrow/widgets/circular_cached_image.dart';
import 'package:instagrow/widgets/default_images.dart';

class DashBoardItem extends StatelessWidget {
  final Plant _plant;

  DashBoardItem(this._plant);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      minimum: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CircularCachedImage(_plant.imageUrl, DASHBOARD_IMAGE_SIZE,
              progressIndicator(context), defaultPlantImage(context)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        _plant.name,
                        style: Styles.dashboardItemTitle(context),
                      ),
                      Text(_plant.timeOffset, style: Styles.plantTimeText(context),)
                    ],
                  ),
                  Container(height: 4,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _plant.moisture.toString() + "   ",
                        style: Styles.dashboardItemDetail(context),
                      ),
                      Text(
                        _plant.temperature.toString(),
                        style: Styles.dashboardItemDetail(context),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
