import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:instagrow/models/sensor_data.dart';

LinkedHashMap _generateDatapoint(double moisture, double temperature) {
  return LinkedHashMap.fromIterables(
    ['moisture', 'temperature'],
    [moisture, temperature],
  );
}

void main() {
  test('fromMap', () {
    LinkedHashMap data = LinkedHashMap.fromIterables(
      ["0600", "0630", "0700", "0730", "0800", "not a time stamp"],
      [
        _generateDatapoint(6, 6),
        _generateDatapoint(6.5, 6.5),
        _generateDatapoint(7, 7),
        _generateDatapoint(7.5, 7.5),
        _generateDatapoint(8, 8),
        _generateDatapoint(100, 100),
      ],
    );

    SensorData sensorData = SensorData.fromMap(data);
    
    expect(sensorData.entryCount, 5);
    expect(sensorData.moistures[12], 6.0);
    expect(sensorData.temperatures[14], 7.0);
  });
}
