import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/dashboard_plant.dart';

class DashBoardItem extends StatelessWidget {
  final int index;
  final DashBoardPlant dashBoardPlant;
  bool lastItem;

  DashBoardItem({this.index, this.dashBoardPlant, this.lastItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.inactiveGray
      ),
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(dashBoardPlant.name), Text(dashBoardPlant.timeUpdated)],
      ),
    );
  }
}
