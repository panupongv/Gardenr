import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/models/qr_validator.dart';
import 'package:instagrow/screens/profile_edit_screen.dart';
import 'package:instagrow/widgets/dashboard_item.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';

class DashBoardScreen extends StatefulWidget {
  final String _title;
  final Function _query;

  DashBoardScreen(this._title, this._query);

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  List<Plant> plants = List();

  @override
  initState() {
    super.initState();
    _onRefresh();
  }

  Future<void> _onAddPressed() async {
    // String xx = await BarcodeScanner.scan();
    String xx = "something scanned";
    if (xx == null) {
      return;
    }

    switch (widget._title) {
      case "My Garden":
        {
          // AWAIT CREATE INSTANCE
          if (QRValidator.addMyPlants(xx)) {
            print("add stuff " + xx.toString());

            Route newPlantPageRoute = CupertinoPageRoute(
                builder: (context) => ProfileEditScreen(
                    null, "", "", PreviousScreen.AddMyPlant, xx));
            Navigator.of(context).push(newPlantPageRoute);
          }
          break;
        }
      case "Following":
        {
          print("scan to follow");
          break;
        }
    }
    // String xx = BarcodeScanner.scan();
  }

  Future<void> _onRefresh() async {
    DateTime refreshedTime = DateTime.now().toUtc();
    List<Plant> queriedPlants = await widget._query(refreshedTime);
    setState(() {
      this.plants = queriedPlants;
    });
  }

  @override
  Widget build(BuildContext context) {
    CustomScrollView scrollView = CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () {
            return _onRefresh();
          },
        ),
        SliverSafeArea(
          top: true,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return DashBoardItem(
                  index: index,
                  plant: plants[index],
                  isMyPlant: widget._title == "My Garden",
                  lastItem: index == plants.length - 1,
                );
              },
              childCount: plants.length,
            ),
          ),
        ),
      ],
    );

    return CupertinoPageScaffold(
      key: GlobalKey<ScaffoldState>(debugLabel: widget._title),
      navigationBar: CupertinoNavigationBar(
        middle: navigationBarTitle(widget._title),
        trailing: GestureDetector(
          child: Icon(CupertinoIcons.add),
          onTap: _onAddPressed,
        ),
      ),
      child: scrollView,
    );
  }
}
