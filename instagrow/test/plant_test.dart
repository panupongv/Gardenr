import 'dart:collection';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:instagrow/models/plant.dart';

void main() {
  String plantId = "PLANTID";
  int utcTimeZone = 0;
  double moisture = 1.0, temperature = 2.0;
  String name = "NAME",
      imageUrl = "IMAGEURL",
      description = "DESCRIPTION",
      timeUpdated = "20200101 0000",
      timeOffset = "1 d",
      ownerId = "OWNERID";
  DateTime refreshedTime = DateTime.parse("20200101 0030");
  bool isPublic = true;
  String defaultJsonString =
      '{"id": "PLANTID", "name": "NAME", "ownerId": "OWNERID", "timeOffset": "1 d", "utcTimeZone": 0, "moisture": 1.0, "temperature": 2.0, "imageUrl": "IMAGEURL", "description": "DESCRIPTION", "isPublic": true}';

  test('fromQueryData', () {
    Map tempMap = Map.fromIterables(<String>[
      'name',
      'utcTimeZone',
      'moisture',
      'temperature',
      'imageUrl',
      'description',
      'timeUpdated',
      'ownerId',
      'isPublic',
    ], <dynamic>[
      name,
      utcTimeZone,
      moisture,
      temperature,
      imageUrl,
      description,
      timeUpdated,
      ownerId,
      isPublic,
    ]);

    LinkedHashMap linkedHashMap = LinkedHashMap.from(tempMap);
    Plant testPlant =
        Plant.fromQueryData(plantId, linkedHashMap, refreshedTime);

    expect(testPlant.id, plantId);
    expect(testPlant.name, name);
    expect(testPlant.utcTimeZone, utcTimeZone);
    expect(testPlant.moisture, moisture);
    expect(testPlant.temperature, temperature);
    expect(testPlant.imageUrl, imageUrl);
    expect(testPlant.description, description);
    expect(testPlant.timeOffset, "30 min");
    expect(testPlant.ownerId, ownerId);
    expect(testPlant.isPublic, isPublic);
  });

  Plant testPlant = Plant(plantId, name, ownerId, timeOffset, utcTimeZone, moisture,
      temperature, imageUrl, description, isPublic);

  test('fromMap', () {
    LinkedHashMap entriesWithNull =
        LinkedHashMap.fromIterables([null, "valid id"], [null, null]);
    List<Plant> plants = Plant.fromMap(entriesWithNull, null);
    expect(plants.isEmpty, true);
  });

  test('fromJson', () {
    Plant fromJsonPlant = Plant.fromJson(jsonDecode(defaultJsonString));
    expect(fromJsonPlant.id, plantId);
    expect(fromJsonPlant.name, name);
    expect(fromJsonPlant.utcTimeZone, utcTimeZone);
    expect(fromJsonPlant.moisture, moisture);
    expect(fromJsonPlant.temperature, temperature);
    expect(fromJsonPlant.imageUrl, imageUrl);
    expect(fromJsonPlant.description, description);
    expect(fromJsonPlant.timeOffset, "1 d");
  });

  test('toJson', () {
    String json = testPlant.toJson();

    expect(json.toString(), defaultJsonString);
  });

  test('hasDuplicateName', () {
    List<Plant> containsDuplicateName = [
      testPlant,
      Plant('', 'some name', '', '', 0, 0, 0, '', '', false),
      Plant('', name, '', '', 0, 0, 0, '', '', false)
    ],
        doesNotContainDuplicateName = [
      testPlant,
      Plant('', 'some name', '', '', 0, 0, 0, '', '', false),
      Plant('', 'some name 2', '', '', 0, 0, 0, '', '', false),
    ];

    expect(Plant.hasDuplicateName(plantId, name, containsDuplicateName), true);
    expect(Plant.hasDuplicateName(plantId, name, doesNotContainDuplicateName),
        false);
  });
}
