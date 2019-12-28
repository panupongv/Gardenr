import 'dart:collection';
import 'package:timeago/timeago.dart' as TimeAgo;

class Plant {
  String id, name, timeOffset, imageUrl, description;
  double moisture, temperature;

  Plant(
      this.id, this.name, this.timeOffset, this.moisture, this.temperature, this.imageUrl, this.description);

  factory Plant.fromQueryData(String id, dynamic data, DateTime refreshedTime) {
    DateTime timeData = DateTime.parse(data['timeUpdated']);
    String timeAgo = TimeAgo.format(timeData, locale: 'en_short', clock: refreshedTime);
    return Plant(id, data['name'], timeAgo,
        data['moisture'], data['temperature'], data['imageUrl'] ?? "", data['description']);
  }

  factory Plant.fromJson(Map<String, dynamic> parsedJson) {
    return Plant(parsedJson['id'], 
                          parsedJson['name'],
                          parsedJson['timeOffset'],
                          parsedJson['moisture'],
                          parsedJson['temperature'],
                          parsedJson['imageUrl'],
                          parsedJson['description']);
  }

  Map<String, dynamic> toJson() {
    return {
      '\"id\"': this.id,
      '\"name\"': '\"${this.name}\"',
      '\"timeOffset\"': '\"${this.timeOffset}\"',
      '\"moisture\"': this.moisture,
      '\"temperature\"': this.temperature,
      '\"imageUrl\"': this.imageUrl,
      '\"description\"': this.description,
    };
  }

  static List<Plant> fromMap(LinkedHashMap map, DateTime refreshedTime) {
    List<Plant> plants = List();
    map.forEach((k, v) {
      if (k != null && v != null)
        plants.add(Plant.fromQueryData(k, v, refreshedTime));
    });
    return plants;
  }

  
  
}
