import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/dashboard_plant.dart';
import 'package:instagrow/widgets/dashboard_item.dart';
import 'package:instagrow/models/user_information.dart';

class DashBoard extends StatefulWidget {
  final String title;
  final dbRef;

  DashBoard(this.title, this.dbRef);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int count = 0;
  Widget build(BuildContext context) {
    var myGardenQuery = FirebaseDatabase.instance
        .reference()
        .child('plants')
        .orderByChild('ownerId')
        .equalTo(UserInformation().userId);
    //.equalTo(UserInformation.userId);
    StreamBuilder builder = StreamBuilder(
      stream: widget.dbRef.onValue,
      builder: (context, snap) {
        if (!snap.hasData || snap.hasError) {
          return CircularProgressIndicator();
        }
        DataSnapshot snapshot = snap.data.snapshot;
        LinkedHashMap value = snapshot.value;
        List items = [];
        value.forEach((k, v) {
          if (k != null) items.add([k, v]);
        });
        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return DashBoardItem(
              index: index,
              plant: DashBoardPlant.fromQueryData(items[index]),
              lastItem: index == items.length - 1,
            );
          },
        );
      },
    );
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("${widget.title}"),
          trailing: Icon(CupertinoIcons.plus_circled),
        ),
        child: builder);
  }
}
