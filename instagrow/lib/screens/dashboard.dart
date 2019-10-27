import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/dashboard_plant.dart';
import 'package:instagrow/widgets/dashboard_item.dart';

class DashBoard extends StatefulWidget {
  final String title;

  DashBoard(this.title);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int count = 0;
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("${widget.title}"),
        trailing: Icon(CupertinoIcons.plus_circled),
      ),
      child: ListView(
        children: [
          DashBoardItem(
              index: 0,
              dashBoardPlant: new DashBoardPlant(
                  name: "Mr. Tree",
                  timeUpdated: "22nd Oct 2019 15:00",
                  moisture: "30",
                  temperature: "25"),
              lastItem: false),
          DashBoardItem(
              index: 0,
              dashBoardPlant: new DashBoardPlant(
                  name: "Mr. Cactus",
                  timeUpdated: "22nd Oct 2019 15:00",
                  moisture: "0",
                  temperature: "40"),
              lastItem: false),
        ],
      ),
    );
  }
}
