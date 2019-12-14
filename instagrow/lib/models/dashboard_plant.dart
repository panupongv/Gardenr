import 'dart:collection';
import 'package:timeago/timeago.dart' as TimeAgo;

class DashBoardPlant {
  String name, timeOffset;
  int id, moisture;
  double temperature;

  DashBoardPlant(
      this.id, this.name, this.timeOffset, this.moisture, this.temperature);

  factory DashBoardPlant.fromQueryData(id, data, refreshedTime) {
    DateTime timeData = DateTime.parse(data['timeUpdated']);
    String timeAgo = TimeAgo.format(timeData, locale: 'en', clock: refreshedTime);
    return DashBoardPlant(int.parse(id), data['name'], timeAgo,
        data['moisture'], data['temperature']);
  }

  factory DashBoardPlant.fromJson(Map<String, dynamic> parsedJson) {
    return DashBoardPlant(parsedJson['id'], 
                          parsedJson['name'],
                          parsedJson['timeOffset'],
                          parsedJson['moisture'],
                          parsedJson['temperature']);
  }

  Map<String, dynamic> toJson() {
    return {
      '\"id\"': this.id,
      '\"name\"': '\"${this.name}\"',
      '\"timeOffset\"': '\"${this.timeOffset}\"',
      '\"moisture\"': this.moisture,
      '\"temperature\"': this.temperature
    };
  }

  static List<DashBoardPlant> fromMap(LinkedHashMap map, DateTime refreshedTime) {
    List<DashBoardPlant> plants = List();
    map.forEach((k, v) {
      if (k != null && v != null)
        plants.add(DashBoardPlant.fromQueryData(k, v, refreshedTime));
    });
    return plants;
  }

  
  
}
