import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/enums.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/models/sensor_data.dart';
import 'package:instagrow/models/user_profile.dart';
import 'package:instagrow/screens/graph_focus_screen.dart';
import 'package:instagrow/screens/other_user_screen.dart';
import 'package:instagrow/screens/profile_edit_screen.dart';
import 'package:instagrow/screens/qr_screen.dart';
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
import 'package:sprintf/sprintf.dart';

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
  UserProfile _ownerProfile;
  SensorData _sensorData;
  bool _loadingData;

  int _selectedDateIndex;
  bool _following;
  List<DateTime> _datesAvailable;

  FixedExtentScrollController _scrollController;

  CircularCachedImage _circularCachedImage;

  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _plant = widget.plant;
    _selectedDateIndex = DATE_RANGE - 1;
    _scrollController =
        FixedExtentScrollController(initialItem: _selectedDateIndex);
    _calculateDatesAvailable();

    _ownerProfile = null;
    DatabaseService.getOtherUserProfile(_plant.ownerId)
        .then((UserProfile profile) {
      setState(() {
        if (profile != null) {
          _ownerProfile = profile;
        }
      });
    });

    _sensorData = null;
    _loadingData = true;
    DatabaseService.getSensorData(
            _plant.id, _datesAvailable[_selectedDateIndex])
        .then((SensorData data) {
      setState(() {
        _sensorData = data;
        _loadingData = false;
      });
    });

    _following = null;
    DatabaseService.plantIsFollowed(_plant).then((bool following) {
      _following = following;
    });

    _streamSubscription =
        DatabaseService.plantProfileStream(_plant.id).listen((Event event) {
      if (event != null &&
          event.snapshot != null &&
          event.snapshot.value != null) {
        setState(() {
          _plant = Plant.fromQueryData(
              _plant.id, event.snapshot.value, DateTime.now().toUtc());
        });
      }
    });
    super.initState();
  }

  String _displayDateFormat(DateTime date) {
    return Jiffy(date).format("EEEE, MMMM do yyyy");
  }

  void _calculateDatesAvailable() {
    DateTime utcTime = DateTime.now().toUtc();
    DateTime plantTime = utcTime.add(Duration(hours: _plant.utcTimeZone));

    _datesAvailable = List.generate(DATE_RANGE, (int value) {
      return plantTime.add(Duration(days: -value));
    }).reversed.toList();
  }

  Widget _buildOverlay() {
    EdgeInsets textInsets = EdgeInsets.symmetric(horizontal: 8, vertical: 8);
    Color backgroundColor = Styles.overlayBackground(context);

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(),
          ),
          Container(
            color: backgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: textInsets,
                  child: navigationBarTextButton(context, "Cancel", () {
                    Navigator.of(context).pop();
                  }),
                ),
                Padding(
                  padding: textInsets,
                  child: navigationBarTextButton(
                    context,
                    "Done",
                    () {
                      setState(() {
                        _selectedDateIndex = _scrollController.selectedItem;
                        _loadingData = true;
                      });
                      _scrollController = FixedExtentScrollController(
                        initialItem: _selectedDateIndex,
                      );
                      DatabaseService.getSensorData(
                              _plant.id, _datesAvailable[_selectedDateIndex])
                          .then((SensorData data) {
                        setState(() {
                          _sensorData = data;
                          _loadingData = false;
                        });
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 120,
            color: backgroundColor,
            child: CupertinoPicker(
              scrollController: _scrollController,
              backgroundColor: backgroundColor,
              children: _datesAvailable
                  .map((DateTime date) => Text(
                        _displayDateFormat(date),
                        style: Styles.datePickerText(context),
                      ))
                  .toList(),
              itemExtent: 30,
              onSelectedItemChanged: null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _moreOptions() async {
    int optionPicked = 0;
    await showCupertinoModalPopup(
        useRootNavigator: false,
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text("More Options"),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text("Edit Plant"),
                onPressed: () {
                  optionPicked = 1;
                  Navigator.of(context).pop();
                },
              ),
              CupertinoActionSheetAction(
                child: Text("Share"),
                onPressed: () {
                  optionPicked = 2;
                  Navigator.of(context).pop();
                },
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          );
        });

    switch (optionPicked) {
      case 0:
        return;
      case 1:
        _openPlantEditScreen();
        break;
      case 2:
        _openQRScreen();
        break;
    }
  }

  Future<void> _openPlantEditScreen() async {
    Navigator.of(context).push(
      PageTransition(
        type: PageTransitionType.fade,
        child: ProfileEditScreen(
            _circularCachedImage.imageProvider,
            _plant.name,
            _plant.description,
            PreviousScreen.EditMyPlant,
            _plant,
            widget.plantList),
      ),
    );
  }

  Future<void> _openQRScreen() async {
    Navigator.of(context).push(CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => QRScreen(_plant)));
  }

  Widget _followButton() {
    if (_following == null) {
      return Text("...", style: Styles.navigationBarTextInActive(context));
    }

    return navigationBarTextButton(context, _following ? "Unfollow" : "Follow",
        () async {
      setState(() {
        _following = null;
      });
      bool toggleFollowingResult =
          await DatabaseService.toggleFollowPlant(_plant);
      if (toggleFollowingResult != null) {
        setState(() {
          _following = toggleFollowingResult;
        });
      }
    });
  }

  Widget _ownerText() {
    if (widget.isMyPlant) {
      return Text(
        'owned by you',
        style: Styles.ownerNameInactive(context),
        textAlign: TextAlign.left,
      );
    }

    if (_ownerProfile != null) {
      return GestureDetector(
        child: Text(
          _ownerProfile.name,
          style: Styles.ownerNameActive(context),
          textAlign: TextAlign.left,
        ),
        onTap: () {
          Route otherUserProfile = CupertinoPageRoute(
              builder: (BuildContext context) =>
                  OtherUserScreen(_ownerProfile, widget.plantList));
          Navigator.of(context).push(otherUserProfile);
        },
      );
    }

    return Text(
      "Not available",
      style: Styles.ownerNameInactive(context),
      textAlign: TextAlign.left,
    );
  }

  Widget _plantLocalTimeText() {
    DateTime now =
        DateTime.now().toUtc().add(Duration(hours: _plant.utcTimeZone));
    String plantLocalTime = Jiffy(now).format("hh:mm");
    String gmt = sprintf(" (GMT%+d)", [_plant.utcTimeZone]);
    return Text(
      plantLocalTime + gmt,
      style: Styles.plantTimeText(context),
    );
  }

  Widget _graphSection() {
    if (_loadingData) {
      return UnconstrainedBox(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_sensorData == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          "NO SENSOR DATA AVAILABLE",
          textAlign: TextAlign.center,
          style: Styles.noDataAvailable(context),
        ),
      );
    }
    TimeSeriesGraphs graphs = TimeSeriesGraphs(_sensorData);
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
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        trailing: widget.isMyPlant
            ? GestureDetector(
                child: Icon(CupertinoIcons.ellipsis),
                onTap: _moreOptions,
              )
            : _followButton(),
      ),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: SafeArea(
            top: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularCachedImage(
                        _plant.imageUrl,
                        PLANT_PROFILE_IMAGE_SIZE,
                        progressIndicator(context),
                        defaultPlantImage(context),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              _plant.name,
                              textAlign: TextAlign.left,
                              style: Styles.plantProfileName(context),
                            ),
                            _ownerText(),
                            Container(
                              height: 8,
                            ),
                            _plantLocalTimeText(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                DescriptionExpandable(_plant.description),
                CupertinoButton(
                  child: Text(
                      _displayDateFormat(_datesAvailable[_selectedDateIndex])),
                  onPressed: () {
                    showCupertinoModalPopup(
                        context: context,
                        useRootNavigator: false,
                        builder: (_) => _buildOverlay());
                  },
                ),
                Container(
                  height: 1,
                  color: Styles.dynamicGray(context),
                ),
                _graphSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
