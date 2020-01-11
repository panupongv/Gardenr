import 'dart:collection';

import 'package:sprintf/sprintf.dart';

class SensorData {
  static const int MAX_LENGTH = 49;
  final List<String> timestamps;
  final List<double> moistures, temperatures;

  SensorData(this.timestamps, this.moistures, this.temperatures);

  factory SensorData.fromMap(LinkedHashMap<dynamic, dynamic> map) {
    List<String> timestamps = List();
    List<double> moistures = List(), temperatures = List();
    for (int i = 0; i < MAX_LENGTH; i++) {
      String hour = sprintf("%02d", [(i/2).floor()]), minute = (i%2==0)?"00":"30"; 
      String databaseTimestamp = hour+minute, formattedTimestamp = "$hour:$minute";

      var dataPoint = map[databaseTimestamp];
      timestamps.add(formattedTimestamp);
      if (dataPoint != null) {
        moistures.add(map[databaseTimestamp]['moisture']);
        temperatures.add(map[databaseTimestamp]['temperature']);
      } else {
        moistures.add(null);
        temperatures.add(null);
      }
    }
    timestamps.add("00:00");
    return SensorData(timestamps, moistures, temperatures);
  }
}
