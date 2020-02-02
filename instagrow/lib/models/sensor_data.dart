import 'dart:collection';

import 'package:sprintf/sprintf.dart';

class SensorData {
  static const int MAX_LENGTH = 49;
  final int _entryCount;
  final List<String> _timestamps;
  final List<double> _moistures, _temperatures;

  SensorData(this._timestamps, this._moistures, this._temperatures, this._entryCount);

  factory SensorData.fromMap(LinkedHashMap<dynamic, dynamic> map) {
    int entryCount = 0;
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
        entryCount++;
      } else {
        moistures.add(null);
        temperatures.add(null);
      }
    }
    timestamps.add("00:00");
    return SensorData(timestamps, moistures, temperatures, entryCount);
  }

  List<String> get timestamps {
    return _timestamps;
  }

  List<double> get moistures {
    return _moistures;
  }

  List<double> get temperatures {
    return _temperatures;
  }

  int get entryCount {
    return _entryCount;
  }
}
