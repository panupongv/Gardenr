import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/models/qr_validator.dart';
import 'package:instagrow/screens/plant_profile_screen.dart';
import 'package:instagrow/screens/profile_edit_screen.dart';
import 'package:instagrow/widgets/dashboard_item.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';
import 'package:instagrow/widgets/search_bar.dart';
import 'package:instagrow/utils/style.dart';

class DashBoardScreen extends StatefulWidget {
  final String _title;
  final Function _query;

  const DashBoardScreen(this._title, this._query);

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen>
    with SingleTickerProviderStateMixin {
  bool showSearch;
  List<Plant> plants, filteredPlants;

  TextEditingController _searchTextController;
  FocusNode _searchFocusNode;

  @override
  initState() {
    super.initState();
    _searchTextController = TextEditingController();
    _searchFocusNode = FocusNode();
    showSearch = false;
    filteredPlants = plants = List();

    _onRefresh();
  }

  Future<void> _onAddPressed() async {
    // String xx = await BarcodeScanner.scan();
    String xx = "something scanned";
    if (xx == null) {
      return;
    }

    switch (widget._title) {
      case "My Garden":
        {
          // AWAIT CREATE INSTANCE
          if (QRValidator.addMyPlants(xx)) {
            print("add stuff " + xx.toString());

            Route newPlantPageRoute = CupertinoPageRoute(
                builder: (context) => ProfileEditScreen(
                    null, "", "", PreviousScreen.AddMyPlant, xx, plants));
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
    List<Plant> queriedPlants = await widget._query(refreshedTime);
    setState(() {
      plants = queriedPlants;
    });
    _updateFilteredPlants();
  }

  void _onItemPressed(int index) {
    Route plantProfileScreen = CupertinoPageRoute(
      builder: (context) {
        if (widget._title == "My Garden") {
          return PlantProfileScreen(plants[index], true, plants);
        }
        return PlantProfileScreen(plants[index], false, null);
      },
    );
    Navigator.of(context).push(plantProfileScreen).then((dynamic _) {
      if (showSearch) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _updateFilteredPlants() {
    String searchText = _searchTextController.text;
    setState(() {
      filteredPlants = plants
          .where((Plant plant) =>
              plant.name.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget searchIcon = showSearch
        ? null
        : GestureDetector(
            child: Icon(CupertinoIcons.search),
            onTap: () {
              setState(() {
                showSearch = true;
              });
            },
          );

    Widget middleWidget = showSearch
        ? DecoratedBox(
            decoration: BoxDecoration(color: Styles.scaffoldBackground),
            child: SearchBar(
              controller: _searchTextController,
              focusNode: _searchFocusNode,
              onUpdate: _updateFilteredPlants,
            ),
          )
        : navigationBarTitle(widget._title);

    Widget trailingWidget = showSearch
        ? Padding(
            padding: EdgeInsets.only(left: 8),
            child: navigationBarTextButton("Cancel", () {
              _searchTextController.clear();
              _searchFocusNode.unfocus();
              setState(() {
                showSearch = false;
              });
            }),
          )
        : GestureDetector(
            child: Icon(CupertinoIcons.add),
            onTap: _onAddPressed,
          );

    CustomScrollView scrollView = CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
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
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _onItemPressed(index);
                  },
                  child: DashBoardItem(
                    index: index,
                    plant: filteredPlants[index],
                    isMyPlant: widget._title == "My Garden",
                    lastItem: index == plants.length - 1,
                  ),
                );
              },
              childCount: filteredPlants.length,
            ),
          ),
        ),
      ],
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: searchIcon,
        middle: middleWidget,
        trailing: trailingWidget,
      ),
      child: scrollView,
    );
  }
}
