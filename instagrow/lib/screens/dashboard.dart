import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/dashboard_plant.dart';
import 'package:instagrow/widgets/dashboard_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DashBoard extends StatefulWidget {
  final String title;
  final dbRef;

  DashBoard(this.title, this.dbRef);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  List<DashBoardPlant> plants = List();

  @override
  initState() {
    super.initState();
    _onRefresh();
  }

  Future<void> _onRefresh() async {
    widget.dbRef.once().then((DataSnapshot snapshot) {
      LinkedHashMap value = snapshot.value;
      setState(() {
        plants.clear();
        value.forEach((k, v) {
          if (k != null && v != null)
            plants.add(DashBoardPlant.fromQueryData(k, v));
        });
        print(plants.length.toString() + " item(s) loaded");
        plants = plants;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    CustomScrollView scrollView = CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: <Widget>[
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
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: scrollView,
    );
  }
}
