import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/sensor_data.dart';
import 'package:instagrow/services/database_service.dart';
import 'package:instagrow/utils/style.dart';
import 'package:instagrow/widgets/date_picker_arrow.dart';
import 'package:instagrow/widgets/time_series_graphs.dart';
import 'package:jiffy/jiffy.dart';

class GraphFocusPopup extends StatefulWidget {
  final String _plantId, _title;
  final Widget _focusedGraph;
  final List<DateTime> _datesAvailable;
  final int _selectedIndex;
  final bool _isSoilMoisture;

  GraphFocusPopup(this._plantId, this._title, this._focusedGraph,
      this._datesAvailable, this._selectedIndex, this._isSoilMoisture);

  @override
  _GraphFocusPopupState createState() => _GraphFocusPopupState();
}

class _GraphFocusPopupState extends State<GraphFocusPopup> {
  Map<int, Widget> _graphs;
  int _selectedIndex;
  bool _loading;

  @override
  void initState() {
    _selectedIndex = widget._selectedIndex;
    _graphs = Map();
    _graphs[_selectedIndex] = widget._focusedGraph;
    _loading = false;
    super.initState();
  }

  String _dateFormat(DateTime date) {
    return Jiffy(date).format("d/MM");
  }

  void _onDateChanged(int newIndex) {
    setState(() {
      _selectedIndex = newIndex;
    });

    if (!_graphs.containsKey(_selectedIndex)) {
      setState(() {
        _loading = true;
      });
      int currentIndex = _selectedIndex;
      DatabaseService.getSensorData(
              widget._plantId, widget._datesAvailable[currentIndex])
          .then((SensorData sensorData) {
        if (sensorData == null) {
          _graphs[currentIndex] = null;
        } else {
          TimeSeriesGraphs timeSeriesGraphs = TimeSeriesGraphs(sensorData);
          _graphs[currentIndex] = widget._isSoilMoisture
              ? timeSeriesGraphs.moistureGraph(context)
              : timeSeriesGraphs.temperatureGraph(context);
        }
        setState(() {
          _loading = false;
        });
      });
    }
  }

  Widget _currentGraph() {
    Widget graph = _graphs[_selectedIndex];
    return _loading
        ? Container(
            color: Colors.amber,
            child: CircularProgressIndicator(),
            width: double.infinity,
            height: double.infinity,
          )
        : graph == null ? Container() : graph;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RotatedBox(
        quarterTurns: 1,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: GestureDetector(
              child: Icon(CupertinoIcons.clear_thick),
              onTap: Navigator.of(context).pop,
            ),
            middle: Text(
              widget._title,
              style: Styles.navigationBarTitle(context),
            ),
            trailing: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                DatePickerArrow(
                  CupertinoIcons.left_chevron,
                  _selectedIndex,
                  0,
                  null,
                  () {
                    _onDateChanged(_selectedIndex - 1);
                  },
                ),
                Text(_dateFormat(widget._datesAvailable[_selectedIndex])),
                DatePickerArrow(
                  CupertinoIcons.right_chevron,
                  _selectedIndex,
                  null,
                  widget._datesAvailable.length - 1,
                  () {
                    _onDateChanged(_selectedIndex + 1);
                  },
                ),
              ],
            ),
            actionsForegroundColor: Styles.activeColor(context),
          ),
          child: SafeArea(
            child: _currentGraph(),
          ),
        ),
      ),
    );
  }
}
