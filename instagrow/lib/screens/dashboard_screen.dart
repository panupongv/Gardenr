import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagrow/utils/enums.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/screens/plant_profile_screen.dart';
import 'package:instagrow/screens/profile_edit_screen.dart';
import 'package:instagrow/services/database_service.dart';
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
  _DashBoardScreenState createState() {
    bool isMyPlant = _contentType == DashBoardContentType.Garden;
    String title = isMyPlant ? "My Garden" : "Following";
    Function queryFunction = isMyPlant
        ? DatabaseService.getMyPlants
        : DatabaseService.getFollowingPlants;
    return _DashBoardScreenState(isMyPlant, title, queryFunction);
  }
}

class _DashBoardScreenState extends State<DashBoardScreen>
    with SingleTickerProviderStateMixin {
  final bool _isMyPlant;
  final String _title;
  final Function _querySource;

  bool _showSearch;
  List<Plant> _plants;
  List<bool> _filteredIndexes;

  String _searchText;
  TextEditingController _searchTextController;
  FocusNode _searchFocusNode;

  _DashBoardScreenState(this._isMyPlant, this._title, this._querySource);

  @override
  initState() {
    super.initState();

    _searchText = "";
    _searchTextController = TextEditingController();
    _searchFocusNode = FocusNode();
    _showSearch = false;
    _plants = List<Plant>();
    _filteredIndexes = List<bool>();

    _onRefresh();
  }

  Future<int> _popCameraOrCodeModal() async {
    int optionPicked = 0;
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Scan QR Code",
              style: Styles.actionSheetAction(context),
            ),
            onPressed: () {
              optionPicked = 1;
              Navigator.of(context).pop();
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              "Enter Textual Code",
              style: Styles.actionSheetAction(context),
            ),
            onPressed: () {
              optionPicked = 2;
              Navigator.of(context).pop();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: Styles.actionSheetAction(context),
          ),
          onPressed: Navigator.of(context).pop,
        ),
      ),
    );

    return optionPicked;
  }

  Future<String> _popEnterCodeModel() async {
    String enteredCode;
    await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(
          "Enter Code",
          style: Styles.dialogTitle(context),
        ),
        content: Column(
          children: <Widget>[
            Text(
              "Enter a shared code obtained from a Gardenr user.",
              style: Styles.dialogContent(context),
            ),
            Container(
              height: 8,
            ),
            CupertinoTextField(
              style: Styles.dialogTextInput(context),
              onChanged: (val) {
                enteredCode = val;
              },
            ),
          ],
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(
              "Cancel",
              style: Styles.dialogActionNormal(context),
            ),
            onPressed: () {
              enteredCode = "";
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: Text(
              "Confirm",
              style: Styles.dialogActionNormal(context),
            ),
            onPressed: Navigator.of(context).pop,
          )
        ],
      ),
    );

    return enteredCode;
  }

  Future<void> _onAddPressed() async {
    int option = await _popCameraOrCodeModal();

    if (option == 0) {
      return;
    }

    String code;

    if (option == 1) {
      code = await BarcodeScanner.scan();
    } else if (option == 2) {
      code = await _popEnterCodeModel();
    }

    if (code == null || code == "") {
      return;
    }

    if (_isMyPlant) {
      _claimScannedCode(code);
    } else {
      _followScannedCode(code);
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
                title: Text(
                  "Oops",
                  style: Styles.dialogTitle(context),
                ),
                content: Text(
                  claimResult.item2,
                  style: Styles.dialogContent(context),
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(
                      "Dismiss",
                      style: Styles.dialogActionNormal(context),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(
                      "Follow",
                      style: Styles.dialogActionNormal(context),
                    ),
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
        builder: (BuildContext context) =>
            quickAlertDialog(context, "Oops", claimResult.item2, "Dismiss"),
      );
    }
  }

  Future<void> _followScannedCode(String scanned) async {
    Tuple2<QrScanResult, String> followResult =
        await DatabaseService.followWithQr(scanned);
    if (followResult.item1 == QrScanResult.Success) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) =>
            quickAlertDialog(context, "Success", followResult.item2, "Dismiss"),
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) =>
            quickAlertDialog(context, "Oops", followResult.item2, "Dismiss"),
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
      _updateFilteredPlants(true);
    }
  }

  void _onItemPressed(int index) async {
    Route plantProfileScreen = CupertinoPageRoute(
      builder: (context) {
        return PlantProfileScreen(
          _plants[index],
          _isMyPlant,
          _isMyPlant ? _plants : null,
        );
      },
    );
    Navigator.of(context).push(plantProfileScreen).then((_) {
      if (_showSearch) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _updateFilteredPlants(bool bypass) {
    String searchText = _searchTextController.text.toLowerCase();
    if (!bypass && searchText.contains(_searchText)) {
      List<bool> filteredIndexes = List.from(_filteredIndexes);
      for (int i = 0; i < _filteredIndexes.length; i++) {
        filteredIndexes[i] =
            _filteredIndexes[i] && _plants[i].name.toLowerCase().contains(searchText);
      }
      setState(() {
        _filteredIndexes = filteredIndexes;
      });
    } else {
      setState(() {
        _filteredIndexes = _plants
            .map((Plant plant) => plant.name.toLowerCase().contains(searchText))
            .toList();
      });
    }
    _searchText = searchText;
  }

  Widget _navigationBarLeadingWidget() {
    return _showSearch
        ? null
        : GestureDetector(
            child: Icon(
              CupertinoIcons.search,
            ),
            onTap: () {
              setState(
                () {
                  _showSearch = true;
                },
              );
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
              onUpdate: () {
                _updateFilteredPlants(false);
              },
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
          DashBoard(_plants, _filteredIndexes, _onRefresh, _onItemPressed, []),
    );
  }
}
