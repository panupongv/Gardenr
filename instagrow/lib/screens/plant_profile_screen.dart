import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/models/user_information.dart';
import 'package:instagrow/screens/graph_focus_screen.dart';
import 'package:instagrow/screens/other_user_screen.dart';
import 'package:instagrow/screens/profile_edit_screen.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/utils/size_config.dart';
import 'package:instagrow/utils/style.dart';
import 'package:instagrow/widgets/circular_cached_image.dart';
import 'package:instagrow/widgets/default_images.dart';
import 'package:instagrow/widgets/description_expandable.dart';
import 'package:instagrow/widgets/graph_title.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';
import 'package:instagrow/widgets/time_series_graphs.dart';
import 'package:jiffy/jiffy.dart';
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
  static const int DATE_RANGE = 7;

  Plant _plant;
  int _selectedDateIndex;
  List<DateTime> _datesAvailable;

  ImageProvider _imageProvider;
  OverlayState _overlayState;
  OverlayEntry _datePickerOverlay;
  FixedExtentScrollController _scrollController;

  UserInformation _ownerInformation;

  @override
  void initState() {
    _plant = widget.plant;
    _selectedDateIndex = DATE_RANGE - 1;
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
    _datePickerOverlay = _buildOverlay();
    super.initState();
  }

  String _displayDateFormat(DateTime date) {
    return Jiffy(date).format("EEEE, MMMM do yyyy");
  }

  String _databaseDateFormat(DateTime date) {
    return Jiffy(date).format("yyyyMMdd");
  }

  void _calculateDatesAvailable() {
    DateTime utcTime = DateTime.now().toUtc();
    DateTime plantTime = utcTime.add(Duration(hours: _plant.utcTimeZone));

    _datesAvailable = List.generate(DATE_RANGE, (int value) {
      return plantTime.add(Duration(days: -value));
    }).reversed.toList();
  }

  OverlayEntry _buildOverlay() {
    EdgeInsets textInsets = EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    return OverlayEntry(
      builder: (BuildContext context) {
        SafeArea overlayWidgets = SafeArea(
          top: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Color.fromARGB(128, 0, 0, 0),
                ),
              ),
              Container(
                color: CupertinoColors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: textInsets,
                      child: navigationBarTextButton("Cancel", () {
                        _datePickerOverlay.remove();
                      }),
                    ),
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
              ),
              Container(
                height: 100,
                child: CupertinoPicker(
                  scrollController: _scrollController,
                  backgroundColor: CupertinoColors.white,
                  children: _datesAvailable
                      .map((DateTime date) => Text(_displayDateFormat(date)))
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
  }

  Future<void> _openPlantEditScreen() async {
    Navigator.of(context).push(
      PageTransition(
        type: PageTransitionType.fade,
        child: ProfileEditScreen(
            _imageProvider,
            _plant.name,
            _plant.description,
            PreviousScreen.EditMyPlant,
            _plant,
            widget.plantList),
      ),
    );
  }

  Widget _ownerText() {
    if (widget.isMyPlant) {
      return Text(
        'owned by you',
        style: Styles.ownerNameInactive(context),
        textAlign: TextAlign.left,
      );
    }
    return FutureBuilder<UserInformation>(
      future: DatabaseService.getOtherUserInformation(widget.plant.ownerId),
      builder: (BuildContext context, AsyncSnapshot<UserInformation> snapshot) {
        if (snapshot != null &&
            snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data != null) {
            _ownerInformation = snapshot.data;
            return GestureDetector(
                child: Text(
                  _ownerInformation.name,
                  style: Styles.ownerNameActive(context),
                  textAlign: TextAlign.left,
                ),
                onTap: () {
                  Route otherUserProfile = CupertinoPageRoute(
                      builder: (BuildContext context) =>
                          OtherUserScreen(snapshot.data));
                  Navigator.of(context).push(otherUserProfile);
                });
          }
        }
        return Text(
          "...",
          style: Styles.ownerNameInactive(context),
          textAlign: TextAlign.left,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        trailing: widget.isMyPlant
            ? navigationBarTextButton("Edit", () {
                _openPlantEditScreen();
              })
            : null,
      ),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: SafeArea(
            top: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularCachedImage(
                          widget.plant.imageUrl,
                          PLANT_PROFILE_IMAGE_SIZE,
                          progressIndicator(context),
                          defaultPlantImage(context)),
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          _plant.name,
                          textAlign: TextAlign.left,
                          style: Styles.plantProfileName(context),
                        ),
                        _ownerText(),
                      ],
                    )
                  ],
                ),
                DescriptionExpandable(_plant.description),
                CupertinoButton(
                  child: Text(
                      _displayDateFormat(_datesAvailable[_selectedDateIndex])),
                  onPressed: () {
                    _overlayState.insert(_datePickerOverlay);
                  },
                ),
                Container(
                  height: 1,
                  color: CupertinoColors.inactiveGray,
                ),
                Container(
                  child: FutureBuilder(
                    future: DatabaseService.getSensorData(
                        _plant.id,
                        _databaseDateFormat(
                            _datesAvailable[_selectedDateIndex])),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot != null && snapshot.data != null) {
                        TimeSeriesGraphs graphs =
                            TimeSeriesGraphs(snapshot.data);
                        Widget moistureGraph = graphs.moistureGraph(),
                            temperatureGraph = graphs.temperatureGraph();
                        return Column(
                          children: <Widget>[
                            GraphTitle(
                              "Moisture",
                              () {
                                Navigator.of(context, rootNavigator: true).push(
                                  CupertinoPageRoute(
                                    fullscreenDialog: true,
                                    builder: (context) {
                                      return GraphFocusScreen(moistureGraph);
                                    },
                                  ),
                                );
                              },
                            ),
                            moistureGraph,
                            GraphTitle(
                              "Temperature",
                              () {
                                Navigator.of(context, rootNavigator: true).push(
                                  CupertinoPageRoute(
                                    fullscreenDialog: true,
                                    builder: (context) {
                                      return GraphFocusScreen(temperatureGraph);
                                    },
                                  ),
                                );
                              },
                            ),
                            temperatureGraph,
                          ],
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        return Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            "NO SENSOR DATA AVAILABLE",
                            textAlign: TextAlign.center,
                          ),
                        );
                      } else {
                        return UnconstrainedBox(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
