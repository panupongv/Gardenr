import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/models/qr_validator.dart';
import 'package:instagrow/screens/graph_focus_screen.dart';
import 'package:instagrow/screens/plant_profile_screen.dart';
import 'package:instagrow/screens/profile_edit_screen.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/widgets/dashboard.dart';
import 'package:instagrow/widgets/dashboard_item.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';
import 'package:instagrow/widgets/search_bar.dart';
import 'package:instagrow/utils/style.dart';

enum DashBoardContentType {
  MyPlants,
  Following,
}

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
  List<Plant> _plants, _filteredPlants;

  TextEditingController _searchTextController;
  FocusNode _searchFocusNode;

  Function _querySource;

  @override
  initState() {
    super.initState();
    _isMyPlant = widget._contentType == DashBoardContentType.MyPlants;
    _title = _isMyPlant ? "My Garden" : "Following";
    _querySource = _isMyPlant
        ? DatabaseService.getMyPlants
        : DatabaseService.getFollowingPlants;

    _searchTextController = TextEditingController();
    _searchFocusNode = FocusNode();
    _showSearch = false;
    _filteredPlants = _plants = List();

    _onRefresh();
  }

  Future<void> _onAddPressed() async {
    String xx = "something scanned";
    if (xx == null) {
      return;
    }

    switch (_title) {
      case "My Garden":
        {
          // AWAIT CREATE INSTANCE
          if (QRValidator.addMyPlants(xx)) {
            Route newPlantPageRoute = CupertinoPageRoute(
                builder: (context) => ProfileEditScreen(
                    null,
                    "",
                    "",
                    PreviousScreen.AddMyPlant,
                    Plant(xx, "", "", "", 0, 0, 0, "", "", true),
                    _plants));
            Navigator.of(context).push(newPlantPageRoute);
          }
          break;
        }
      case "Following":
        {
          print("scan to follow");
          _onRefresh();
          break;
        }
    }
  }

  Future<void> _onRefresh() async {
    DateTime refreshedTime = DateTime.now().toUtc();
    List<Plant> queriedPlants = await _querySource(refreshedTime);
    setState(() {
      _plants = queriedPlants;
    });
    _updateFilteredPlants();
  }

  void _onItemPressed(int index) {
    Route plantProfileScreen = CupertinoPageRoute(
      builder: (context) {
        if (_isMyPlant) {
          return PlantProfileScreen(_filteredPlants[index], true, _plants);
        }
        return PlantProfileScreen(_filteredPlants[index], false, null);
      },
    );
    Navigator.of(context).push(plantProfileScreen).then((_) {
      if (_showSearch) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _updateFilteredPlants() {
    String searchText = _searchTextController.text;
    setState(() {
      _filteredPlants = _plants
          .where((Plant plant) =>
              plant.name.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  Widget _navigationBarLeadingWidget() {
    return _showSearch
        ? null
        : GestureDetector(
            child: Icon(CupertinoIcons.search),
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
        : navigationBarTitle(_title);
  }

  Widget _navigationBarTrailingWidget() {
    return _showSearch
        ? Padding(
            padding: EdgeInsets.only(left: 8),
            child: navigationBarTextButton("Cancel", () {
              _searchTextController.clear();
              _searchFocusNode.unfocus();
              setState(() {
                _showSearch = false;
              });
            }),
          )
        : GestureDetector(
            child: Icon(CupertinoIcons.add),
            onTap: _onAddPressed,
          );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: _navigationBarLeadingWidget(),
        middle: _navigationBarMiddleWidget(),
        trailing: _navigationBarTrailingWidget(),
      ),
      child: DashBoard(_filteredPlants, _onRefresh, _onItemPressed),
    );
  }
}
