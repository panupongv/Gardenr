import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/sensor_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TimeSeriesGraphs {
  final SensorData _sensorData;
  static final EdgeInsets insets = EdgeInsets.only(top: 4, bottom: 4);

  TimeSeriesGraphs(this._sensorData);

  Widget moistureGraph() {
    return _defaultGraphLayout(
      splineGraph("Moisture", _sensorData.moistures, 0, 100, 20, "{value}%"),
    );
  }

  Widget temperatureGraph() {
    return _defaultGraphLayout(
      splineGraph("Temperature", _sensorData.temperatures, 0, 40, 5, "{value}°C"),
    );
  }

  Widget _defaultGraphLayout(Widget child) {
    return Padding(
      padding: insets,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: insets,
          child: splineGraph(
              "Moisture", _sensorData.moistures, 0, 100, 20, "{value}%"),
        ),
        Padding(
          padding: insets,
          child: splineGraph(
              "Temperature", _sensorData.temperatures, 0, 40, 5, "{value}°C"),
        ),
      ],
    );
  }

  SfCartesianChart splineGraph(String title, List<double> data, double yMinimum,
      double yMaximum, double yInterval, String yFormat) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
          minimum: 0,
          maximum: SensorData.MAX_LENGTH.toDouble(),
          interval: 6,
          majorGridLines: MajorGridLines(width: 0),
          labelPlacement: LabelPlacement.onTicks),
      primaryYAxis: NumericAxis(
          minimum: yMinimum,
          maximum: yMaximum,
          interval: yInterval,
          axisLine: AxisLine(width: 0),
          edgeLabelPlacement: EdgeLabelPlacement.none,
          labelFormat: yFormat,
          majorTickLines: MajorTickLines(size: 0)),
      series: getDefaultSplineSeries(data),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '',
        canShowMarker: false,
      ),
    );
  }

  List<SplineSeries<_ChartDataPoint, String>> getDefaultSplineSeries(
      List<double> data) {
    final List<_ChartDataPoint> chartData =
        List.generate(SensorData.MAX_LENGTH, (int index) {
      return _ChartDataPoint(_sensorData.timestamps[index], data[index]);
    });
    return <SplineSeries<_ChartDataPoint, String>>[
      SplineSeries<_ChartDataPoint, String>(
        color: CupertinoColors.activeBlue,
        enableTooltip: true,
        dataSource: chartData,
        xValueMapper: (_ChartDataPoint point, _) => point.x,
        yValueMapper: (_ChartDataPoint point, _) => point.y,
      ),
    ];
  }
}

class _ChartDataPoint {
  String x;
  double y;
  _ChartDataPoint(this.x, this.y);
}
