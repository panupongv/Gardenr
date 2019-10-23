import 'package:flutter/material.dart';

Widget section(String title, Color color) {
  return Container(decoration: BoxDecoration(color: color), child: Text(title));
}

class LocationDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Bitchj"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            section("One", Colors.red),
            section("Oneeeeeeeeeee", Colors.green),
            section("Oneessssssee", Colors.purple),
          ],
        ));
  }
}
