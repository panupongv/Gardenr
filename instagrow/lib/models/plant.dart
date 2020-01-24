import 'dart:collection';
import 'package:timeago/timeago.dart' as TimeAgo;

class Plant {
  String id, name, timeOffset, imageUrl, description, ownerId;
  int utcTimeZone;
  double moisture, temperature;
  bool isPublic;

  Plant(
      this.id,
      this.name,
      this.ownerId,
      this.timeOffset,
      this.utcTimeZone,
      this.moisture,
      this.temperature,
      this.imageUrl,
      this.description,
      this.isPublic);

  factory Plant.fromQueryData(
      String id, LinkedHashMap dataMap, DateTime refreshedTime) {
    DateTime timeData = DateTime.parse(dataMap['timeUpdated']);
    DateTime timeUpdatedInUtc =
        timeData.add(Duration(hours: dataMap['utcTimeZone']));
    String timeAgo = TimeAgo.format(timeUpdatedInUtc,
        locale: 'en_short', clock: refreshedTime);

    if (dataMap['timeUpdated'] != null && dataMap['utcTimeZone'] != null) {
      timeData = DateTime.parse(dataMap['timeUpdated']);
      timeUpdatedInUtc = timeData.add(Duration(hours: dataMap['utcTimeZone']));
      timeAgo = TimeAgo.format(timeUpdatedInUtc,
          locale: 'en_short', clock: refreshedTime);
    } else {
      timeAgo = "";
    }

    return Plant(
        id,
        dataMap['name'],
        dataMap['ownerId'],
        timeAgo,
        dataMap['utcTimeZone'] ?? 0,
        dataMap['moisture'] ?? 0,
        dataMap['temperature'] ?? 0,
        dataMap['imageUrl'] ?? "",
        dataMap['description'] ?? "",
        dataMap['isPublic']);
  }

  static List<Plant> fromMap(LinkedHashMap nestedMap, DateTime refreshedTime) {
    List<Plant> plants = List();
    nestedMap.forEach((plantId, dataMap) {
      if (plantId != null && dataMap != null) print(plantId);
      plants.add(Plant.fromQueryData(plantId, dataMap, refreshedTime));
    });
    return plants;
  }

  factory Plant.fromJson(Map<String, dynamic> parsedJson) {
    return Plant(
        parsedJson['id'],
        parsedJson['name'],
        parsedJson['ownerId'],
        parsedJson['timeOffset'],
        parsedJson['utcTimeZone'],
        parsedJson['moisture'],
        parsedJson['temperature'],
        parsedJson['imageUrl'],
        parsedJson['description'],
        parsedJson['isPublic']);
  }

  String toJson() {
    String descriptionEscaped =
        this.description.replaceAll("\n", "\\n").replaceAll('\"', '\\"');

    String json = "{";
    json += '"id": "$id", ';
    json += '"name": "$name", ';
    json += '"ownerId": "$ownerId", ';
    json += '"timeOffset": "$timeOffset", ';
    json += '"utcTimeZone": $utcTimeZone, ';
    json += '"moisture": $moisture, ';
    json += '"temperature": $temperature, ';
    json += '"imageUrl": "$imageUrl", ';
    json += '"description": "$descriptionEscaped", ';
    json += '"isPublic": $isPublic';
    json += "}";
    return json;
  }

  static bool hasDuplicateName(
      String plantId, String name, List<Plant> plants) {
    return plants
        .where((Plant current) => current.id != plantId)
        .where((Plant current) => current.name == name)
        .isNotEmpty;
  }
}
