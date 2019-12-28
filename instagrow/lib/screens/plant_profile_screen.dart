import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/screens/profile_edit_screen.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/utils/dimension_config.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';
import 'package:page_transition/page_transition.dart';

class PlantProfileScreen extends StatefulWidget {
  final Plant plant;
  final bool isMyPlants;

  PlantProfileScreen(this.plant, this.isMyPlants);

  @override
  _PlantProfileScreenState createState() => _PlantProfileScreenState();
}

class _PlantProfileScreenState extends State<PlantProfileScreen> {
  ImageProvider _imageProvider;
  Plant plant;

  @override
  void initState() {
    plant = widget.plant;
    DatabaseService.plantProfileStream(plant.id).listen((Event event) {
      print("Channged");
      if (event.snapshot != null && event.snapshot.value != null) {
        print("Event snap not null");
        setState(() {
          plant = Plant.fromQueryData(
              plant.id, event.snapshot.value, DateTime.now().toUtc());
        });
      }
    });
    super.initState();
  }

  Future<void> _openPlantEditScreen() async {
    Navigator.of(context).push(
      PageTransition(
        type: PageTransitionType.fade,
        child: ProfileEditScreen(_imageProvider, plant.name, plant.description,
            PreviousScreen.EditMyPlant, plant.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Container defaultPlantImage = Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/defaultplant.png'),
        ),
      ),
      width: PLANT_PROFILE_IMAGE_SIZE,
      height: PLANT_PROFILE_IMAGE_SIZE,
    );
    ClipRRect imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(PLANT_PROFILE_IMAGE_CIRCULAR_BORDER),
      child: CachedNetworkImage(
        imageUrl: plant.imageUrl,
        imageBuilder: (BuildContext context, ImageProvider imageProvider) {
          _imageProvider = imageProvider;
          return Container(
            width: PLANT_PROFILE_IMAGE_SIZE,
            height: PLANT_PROFILE_IMAGE_SIZE,
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          );
        },
        placeholder: (context, url) => defaultPlantImage,
        errorWidget: (context, url, error) => defaultPlantImage,
      ),
    );

    return CupertinoPageScaffold(
      // child: imageWidget,
      navigationBar: CupertinoNavigationBar(
        trailing: widget.isMyPlants
            ? navigationBarTextButton("Edit", () {
                _openPlantEditScreen();
              })
            : null,
      ),
      child: SafeArea(
        top: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16),
                  child: imageWidget,
                ),
                Text(
                  plant.name,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 12, right: 12, bottom: 16),
              child: Text(plant.description),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(height: 100, child: Text("Item 1")),
                    Container(height: 100, child: Text("Item 2")),
                    Container(height: 100, child: Text("Item 3")),
                    Container(height: 100, child: Text("Item 4")),
                    Container(height: 100, child: Text("Item 5")),
                    Container(height: 100, child: Text("Item 6")),
                    Container(height: 100, child: Text("Item 7")),
                    Container(height: 100, child: Text("Item 8")),
                    Container(height: 100, child: Text("Item 9")),
                    Container(height: 100, child: Text("Item 10")),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
