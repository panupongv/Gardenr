import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/models/qr_validator.dart';
import 'package:instagrow/screens/plant_profile_screen.dart';
import 'package:instagrow/screens/profile_edit_screen.dart';
import 'package:instagrow/widgets/dashboard_item.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';
import 'package:instagrow/widgets/search_bar.dart';

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
  List<Plant> plants = List();

  TextEditingController _searchTextController = new TextEditingController();
  FocusNode _searchFocusNode = new FocusNode();
  Animation _animation;
  AnimationController _animationController;

  @override
  initState() {
    super.initState();

    showSearch = false;
    _onRefresh();

    _animationController = AnimationController(
      duration: new Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
    // _animation = ProxyAnimation();
    _searchFocusNode.addListener(() {
      if (!_animationController.isAnimating) {
        _animationController.forward();
      }
    });
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
                    null, "", "", PreviousScreen.AddMyPlant, xx));
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
      this.plants = queriedPlants;
    });
  }

  void _onItemPressed(int index) {
    setState(() {
      showSearch = false;
    });
    Route plantProfileScreen = CupertinoPageRoute(
      builder: (context) {
        return PlantProfileScreen(plants[index], widget._title == "My Garden");
      },
    );
    Navigator.of(context).push(plantProfileScreen);
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Container(
                    child: DashBoardItem(
                      index: index,
                      plant: plants[index],
                      isMyPlant: widget._title == "My Garden",
                      lastItem: index == plants.length - 1,
                    ),
                  ),
                );
              },
              childCount: plants.length,
            ),
          ),
        ),
      ],
    );

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
        ? IOSSearchBar(
            controller: _searchTextController,
            focusNode: _searchFocusNode,
            animation: _animation,
            onCancel: _cancelSearch,
            onClear: _clearSearch,
            onUpdate: (String x) {
              print(x);
            },
          )
        : navigationBarTitle(widget._title);

    Widget addIcon = showSearch
        ? null
        : GestureDetector(
            child: Icon(CupertinoIcons.add),
            onTap: _onAddPressed,
          );

    return CupertinoPageScaffold(
      key: GlobalKey<ScaffoldState>(debugLabel: widget._title),
      navigationBar: CupertinoNavigationBar(
        leading: searchIcon,
        middle: middleWidget,
        trailing: addIcon,
      ),
      child: scrollView,
    );
  }

  void _cancelSearch() {
    _searchTextController.clear();
    _searchFocusNode.unfocus();
    _animationController.reverse();
    setState(() {
      showSearch = false;
    });
  }

  void _clearSearch() {
    _searchTextController.clear();
  }
}
