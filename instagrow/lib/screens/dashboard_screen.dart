import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/enums.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/screens/plant_profile_screen.dart';
import 'package:instagrow/screens/profile_edit_screen.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/widgets/dashboard.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';
import 'package:instagrow/widgets/quick_dialog.dart';
import 'package:instagrow/widgets/search_bar.dart';
import 'package:instagrow/utils/style.dart';
import 'package:tuple/tuple.dart';

class DashBoardScreen extends StatefulWidget {
  final DashBoardContentType _contentType;

  const DashBoardScreen(this._contentType);

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen>
    with SingleTickerProviderStateMixin {
  String _title;
  bool _isMyPlant, _showSearch;
  List<Plant> _plants;
  List<bool> _filteredPlants;

  TextEditingController _searchTextController;
  FocusNode _searchFocusNode;

  Function _querySource;

  @override
  initState() {
    super.initState();
    _isMyPlant = widget._contentType == DashBoardContentType.Garden;
    _title = _isMyPlant ? "My Garden" : "Following";
    _querySource = _isMyPlant
        ? DatabaseService.getMyPlants
        : DatabaseService.getFollowingPlants;

    _searchTextController = TextEditingController();
    _searchFocusNode = FocusNode();
    _showSearch = false;
    _plants = List<Plant>();
    _filteredPlants = List<bool>();

    _onRefresh();
  }

  Future<void> _onAddPressed() async {
    String scanned = await BarcodeScanner.scan();
    if (scanned == null) {
      return;
    }

    if (_isMyPlant) {
      _claimScannedCode(scanned);
    } else {
      _followScannedCode(scanned);
    }
  }

  Future<void> _claimScannedCode(String scanned) async {
    Tuple2<QrScanResult, String> claimResult =
        await DatabaseService.claimWithQr(scanned);
    if (claimResult.item1 == QrScanResult.Success) {
      Route newPlantPageRoute = CupertinoPageRoute(
          builder: (context) => ProfileEditScreen(
              null,
              "",
              "",
              PreviousScreen.AddMyPlant,
              Plant(claimResult.item2, "", "", "", 0, 0, 0, "", "", true),
              _plants));
      Navigator.of(context).push(newPlantPageRoute);
    } else if (claimResult.item1 == QrScanResult.AlreadyHasOwner) {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
                title: Text("Oops"),
                content: Text(claimResult.item2),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text("Dismiss"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text("Follow"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _followScannedCode(scanned);
                    },
                  ),
                ],
              ));
    } else {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => getQuickAlertDialog(
              context, "Oops", claimResult.item2, "Dismiss"));
    }
  }

  Future<void> _followScannedCode(String scanned) async {
    Tuple2<QrScanResult, String> followResult =
        await DatabaseService.followWithQr(scanned);
    if (followResult.item1 == QrScanResult.Success) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => getQuickAlertDialog(
            context, "Success", followResult.item2, "Dismiss"),
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => getQuickAlertDialog(
            context, "Oops", followResult.item2, "Dismiss"),
      );
    }
  }

  Future<void> _onRefresh() async {
    DateTime refreshedTime = DateTime.now().toUtc();
    List<Plant> queriedPlants = await _querySource(refreshedTime);
    if (queriedPlants != null) {
      setState(() {
        _plants = queriedPlants;
      });
      _updateFilteredPlants();
    }
  }

  void _onItemPressed(int index) async {
    Route plantProfileScreen = CupertinoPageRoute(
      builder: (context) {
        // return CupertinoPageScaffold(navigationBar: CupertinoNavigationBar(middle: Text("FUCK"),), child: Text("xxxx"),);
        return PlantProfileScreen(
          _plants[index],
          _isMyPlant,
          _isMyPlant ? _plants : null,
        );
      },
    );
    // Navigator.of(context).push(plantProfileScreen);
    Navigator.of(context).push(plantProfileScreen).then((_) {
      if (_showSearch) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _updateFilteredPlants() {
    String searchText = _searchTextController.text.toLowerCase();
    setState(() {
      _filteredPlants = _plants
          .map((Plant plant) => plant.name.toLowerCase().contains(searchText))
          .toList();
    });
  }

  Widget _navigationBarLeadingWidget() {
    return _showSearch
        ? null
        : GestureDetector(
            child: Icon(
              CupertinoIcons.search,
            ),
            onTap: () {
              setState(() {
                _showSearch = true;
              });
            },
          );
  }

  Widget _navigationBarMiddleWidget() {
    return _showSearch
        ? DecoratedBox(
            decoration: BoxDecoration(color: Styles.scaffoldBackground),
            child: SearchBar(
              controller: _searchTextController,
              focusNode: _searchFocusNode,
              onUpdate: _updateFilteredPlants,
            ),
          )
        : navigationBarTitle(context, _title);
  }

  Widget _navigationBarTrailingWidget() {
    return _showSearch
        ? Padding(
            padding: EdgeInsets.only(left: 8),
            child: navigationBarTextButton(context, "Cancel", () {
              _searchTextController.clear();
              _searchFocusNode.unfocus();
              setState(() {
                _showSearch = false;
              });
            }),
          )
        : GestureDetector(
            child: Icon(
              CupertinoIcons.add,
            ),
            onTap: _onAddPressed,
          );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        actionsForegroundColor: Styles.activeColor(context),
        leading: _navigationBarLeadingWidget(),
        middle: _navigationBarMiddleWidget(),
        trailing: _navigationBarTrailingWidget(),
      ),
       child:
          DashBoard(_plants, _filteredPlants, _onRefresh, _onItemPressed, []),
    );
  }
}
