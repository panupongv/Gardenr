import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/models/sensor_data.dart';
import 'package:instagrow/screens/profile_edit_screen.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/utils/dimension_config.dart';
import 'package:instagrow/widgets/date_picker.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';
import 'package:instagrow/widgets/time_series_graphs.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class PlantProfileScreen extends StatefulWidget {
  final Plant plant;
  final bool isMyPlant;
  final List<Plant> plantList;

  PlantProfileScreen(this.plant, this.isMyPlant, this.plantList);

  @override
  _PlantProfileScreenState createState() => _PlantProfileScreenState();
}

class _PlantProfileScreenState extends State<PlantProfileScreen> {
  Plant _plant;
  int _selectedDateIndex;
  List<DateTime> _datesAvailable;
  DateFormat _datePickerItemFormat, _databaseDataFormat;

  ImageProvider _imageProvider;
  OverlayState _overlayState;
  OverlayEntry _datePickerOverlay;
  FixedExtentScrollController _scrollController;

  @override
  void initState() {
    _plant = widget.plant;
    _selectedDateIndex = 6;
    _datePickerItemFormat = DateFormat("EEEE, do MMMM yyyy");
    _databaseDataFormat = DateFormat("yyyyMMdd");
    _scrollController =
        FixedExtentScrollController(initialItem: _selectedDateIndex);
    _calculateDatesAvailable();

    DatabaseService.plantProfileStream(_plant.id).listen((Event event) {
      if (event.snapshot != null && event.snapshot.value != null) {
        setState(() {
          _plant = Plant.fromQueryData(
              _plant.id, event.snapshot.value, DateTime.now().toUtc());
        });
      }
    });
    _overlayState = Overlay.of(context);
    _datePickerOverlay = OverlayEntry(
      builder: (BuildContext context) {
        SafeArea overlayWidgets = SafeArea(
          top: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Color.fromARGB(128, 0, 0, 0),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  navigationBarTextButton("Cancel", () {
                    _datePickerOverlay.remove();
                  }),
                  navigationBarTextButton(
                    "Done",
                    () {
                      _datePickerOverlay.remove();
                      setState(() {
                        _selectedDateIndex = _scrollController.selectedItem;
                      });
                      _scrollController = FixedExtentScrollController(
                          initialItem: _selectedDateIndex);
                    },
                  ),
                ],
              ),
              Container(
                height: 100,
                child: CupertinoPicker(
                  scrollController: _scrollController,
                  backgroundColor: CupertinoColors.inactiveGray,
                  children: _datesAvailable
                      .map((DateTime date) =>
                          Text(_datePickerItemFormat.format(date)))
                      .toList(),
                  itemExtent: 30,
                  onSelectedItemChanged: null,
                ),
              ),
            ],
          ),
        );
        _scrollController.jumpToItem(_selectedDateIndex);
        return overlayWidgets;
      },
    );
    super.initState();
  }

  void _calculateDatesAvailable() {
    DateTime utcTime = DateTime.now().toUtc();
    DateTime plantTime = utcTime.add(Duration(hours: _plant.utcTimeZone));

    _datesAvailable = List.generate(7, (int value) {
      return plantTime.add(Duration(days: -value));
    }).reversed.toList();
  }

  Future<void> _openPlantEditScreen() async {
    Navigator.of(context).push(
      PageTransition(
        type: PageTransitionType.fade,
        child: ProfileEditScreen(_imageProvider, _plant.name,
            _plant.description, PreviousScreen.EditMyPlant, _plant.id, widget.plantList),
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
        imageUrl: _plant.imageUrl,
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
        trailing: widget.isMyPlant
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
                  _plant.name,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 12, right: 12, bottom: 16),
              child: Text(_plant.description ?? ""),
            ),
            CupertinoButton(
              child: Text(_datePickerItemFormat
                  .format(_datesAvailable[_selectedDateIndex])),
              onPressed: () {
                _overlayState.insert(_datePickerOverlay);
                print(_selectedDateIndex);

                _scrollController.jumpToItem(_selectedDateIndex);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                  child: FutureBuilder(
                future: DatabaseService.getSensorData(
                    _plant.id,
                    _databaseDataFormat
                        .format(_datesAvailable[_selectedDateIndex])),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  print(_databaseDataFormat
                      .format(_datesAvailable[_selectedDateIndex]));
                  if (snapshot != null && snapshot.data != null) {
                    return TimeSeriesGraphs(snapshot.data);
                  }
                  return Text('wait');
                },
              )),
            )
          ],
        ),
      ),
    );
  }
}
