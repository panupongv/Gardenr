import 'dart:collection';
import 'package:timeago/timeago.dart' as TimeAgo;

class Plant {
  final String _id, _name, _timeOffset, _imageUrl, _description, _ownerId;
  final int _utcTimeZone;
  final double _moisture, _temperature;
  final bool _isPublic;

  Plant(
      this._id,
      this._name,
      this._ownerId,
      this._timeOffset,
      this._utcTimeZone,
      this._moisture,
      this._temperature,
      this._imageUrl,
      this._description,
      this._isPublic);

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
      if (plantId != null && dataMap != null) {
        plants.add(Plant.fromQueryData(plantId, dataMap, refreshedTime));
      }
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
        this._description.replaceAll("\n", "\\n").replaceAll('\"', '\\"');

    String json = "{";
    json += '"id": "$_id", ';
    json += '"name": "$_name", ';
    json += '"ownerId": "$_ownerId", ';
    json += '"timeOffset": "$_timeOffset", ';
    json += '"utcTimeZone": $_utcTimeZone, ';
    json += '"moisture": $_moisture, ';
    json += '"temperature": $_temperature, ';
    json += '"imageUrl": "$_imageUrl", ';
    json += '"description": "$descriptionEscaped", ';
    json += '"isPublic": $_isPublic';
    json += "}";
    return json;
  }

  static bool hasDuplicateName(
      String plantId, String name, List<Plant> plants) {
    if (plants == null) {
      return false;
    }
    return plants
        .where((Plant current) => current.id != plantId)
        .where((Plant current) => current.name == name)
        .isNotEmpty;
  }

  String get id {
    return _id;
  }

  String get name {
    return _name;
  }

  String get ownerId {
    return _ownerId;
  }

  String get timeOffset {
    return _timeOffset;
  }

  String get description {
    return _description;
  }

  String get imageUrl {
    return _imageUrl;
  }

  double get moisture {
    return _moisture;
  }

  double get temperature {
    return _temperature;
  }

  int get utcTimeZone {
    return _utcTimeZone;
  }

  bool get isPublic {
    return _isPublic;
  }
}
