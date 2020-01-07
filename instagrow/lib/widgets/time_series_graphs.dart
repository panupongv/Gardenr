import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/sensor_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TimeSeriesGraphs extends StatelessWidget {
  final SensorData _sensorData;

  TimeSeriesGraphs(this._sensorData);

  @override
  Widget build(BuildContext context) {
    EdgeInsets insets = EdgeInsets.only(top: 4, bottom: 4);
    return Column(
      children: <Widget>[
        Padding(
          padding: insets,
          child: splineGraph(
              "Moisture", _sensorData.moistures, 0, 100, "{value}%"),
        ),
        Padding(
          padding: insets,
          child: splineGraph(
              "Temperature", _sensorData.temperatures, 0, 40, "{value}°C"),
        ),
      ],
    );
  }

  SfCartesianChart splineGraph(String title, List<double> data, double yMinimum,
      double yMaximum, String yFormat) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      title: ChartTitle(
        text: title,
      ),
      primaryXAxis: CategoryAxis(
          minimum: 0,
          maximum: _sensorData.maxLength.toDouble() - 1,
          interval: 6,
          majorGridLines: MajorGridLines(width: 0),
          labelPlacement: LabelPlacement.onTicks),
      primaryYAxis: NumericAxis(
          minimum: yMinimum,
          maximum: yMaximum,
          axisLine: AxisLine(width: 0),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
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

  List<SplineSeries<ChartSampleData, String>> getDefaultSplineSeries(
      List<double> data) {
    final List<ChartSampleData> chartData =
        List.generate(_sensorData.maxLength, (int index) {
      return ChartSampleData(_sensorData.timeStamps[index], data[index]);
    });
    return <SplineSeries<ChartSampleData, String>>[
      SplineSeries<ChartSampleData, String>(
        color: CupertinoColors.activeBlue,
        enableTooltip: true,
        dataSource: chartData,
        xValueMapper: (ChartSampleData point, _) => point.x,
        yValueMapper: (ChartSampleData point, _) => point.y,
        // markerSettings: MarkerSettings(isVisible: true),
      ),
    ];
  }
}

class ChartSampleData {
  String x;
  double y;
  ChartSampleData(this.x, this.y);
}
