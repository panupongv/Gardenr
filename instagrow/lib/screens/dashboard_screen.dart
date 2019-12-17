import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/dashboard_plant.dart';
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
  List<DashBoardPlant> plants = List();

  @override
  initState() {
    super.initState();
    _onRefresh();
  }

  Future<void> _onRefresh() async {
    DateTime refreshedTime = DateTime.now().toUtc();
    var queriedPlants = await widget._query(refreshedTime);
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
      navigationBar: CupertinoNavigationBar(middle: navigationBarTitle(widget._title)),
      child: scrollView,
    );
  }
}
