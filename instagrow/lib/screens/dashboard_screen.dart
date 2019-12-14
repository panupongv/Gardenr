import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/dashboard_plant.dart';
import 'package:instagrow/widgets/dashboard_item.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';

class DashBoardScreen extends StatefulWidget {
  final String _title;
  final FirebaseUser _user;
  final Function _query;

  DashBoardScreen(this._title, this._user, this._query);

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
    var queriedPlants = await widget._query(widget._user, refreshedTime);
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
        // CupertinoSliverNavigationBar(
        //   largeTitle: Text(widget._title),
        // ),
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
      navigationBar: CupertinoNavigationBar(middle: navigationBarText(widget._title)),
      child: scrollView,
    );
  }
}
