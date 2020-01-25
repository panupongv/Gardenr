import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/enums.dart';
import 'package:instagrow/utils/style.dart';

class ContentSegmentController extends StatefulWidget {
  final Function _valueChangedCallback;

  ContentSegmentController(this._valueChangedCallback);

  @override
  _ContentSegmentControllerState createState() =>
      _ContentSegmentControllerState();
}

class _ContentSegmentControllerState extends State<ContentSegmentController> {
  DashBoardContentType _selectedValue;

  @override
  void initState() {
    _selectedValue = DashBoardContentType.MyPlants;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: CupertinoSegmentedControl(
        groupValue: _selectedValue,
        children: Map.fromIterables([
          DashBoardContentType.MyPlants,
          DashBoardContentType.Following
        ], [
          Text(
            "Garden",
            style: Styles.segmentControl,
          ),
          Text(
            "Following",
            style: Styles.segmentControl,
          )
        ]),
        onValueChanged: (DashBoardContentType value) {
          setState(() {
            _selectedValue = value;
          });
          widget._valueChangedCallback(value);
        },
        selectedColor: Styles.segmentControlSelected(context),
        pressedColor: Styles.segmentControlPressed(context),
      ),
    );
  }
}
