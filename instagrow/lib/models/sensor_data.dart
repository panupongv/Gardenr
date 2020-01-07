import 'dart:collection';

import 'package:sprintf/sprintf.dart';

class SensorData {
  final int maxLength;
  final List<String> timeStamps;
  final List<double> moistures, temperatures;

  SensorData(this.maxLength, this.timeStamps, this.moistures, this.temperatures);

  factory SensorData.fromMap(LinkedHashMap<dynamic, dynamic> map) {
    List<String> timeStamps = List();
    for (int i = 0; i < 24; i++) {
      timeStamps.add(sprintf("%02d00", [i]));
      timeStamps.add(sprintf("%02d30", [i]));
    }

    List<String> formattedTimeStamps = [];
    List<double> moistures = [], temperatures = [];

    timeStamps.forEach((String timeStamp) {
      formattedTimeStamps
          .add(timeStamp.substring(0, 2) + ":" + timeStamp.substring(2, 4));
      var timePoint = map[timeStamp];
      if (timePoint != null) {
        moistures.add(map[timeStamp]['moisture']);
        temperatures.add(map[timeStamp]['temperature']);
      } else {
        moistures.add(null);
        temperatures.add(null);
      }
    });

    return SensorData(
        timeStamps.length, formattedTimeStamps, moistures, temperatures);
  }
}
