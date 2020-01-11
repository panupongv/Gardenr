import 'dart:collection';
import 'dart:convert';
import 'dart:math';

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
      timeOffset = "1 d";
  DateTime refreshedTime = DateTime.parse("20200101 0030");

  String defaultJsonString =
      '{"id": "PLANTID", "name": "NAME", "timeOffset": "1 d", "utcTimeZone": 0, "moisture": 1.0, "temperature": 2.0, "imageUrl": "IMAGEURL", "description": "DESCRIPTION"}';

  test('fromQueryData', () {
    Map tempMap = Map.fromIterables(<String>[
      'name',
      'utcTimeZone',
      'moisture',
      'temperature',
      'imageUrl',
      'description',
      'timeUpdated',
    ], <dynamic>[
      name,
      utcTimeZone,
      moisture,
      temperature,
      imageUrl,
      description,
      timeUpdated,
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
  });

  Plant testPlant = Plant(plantId, name, timeOffset, utcTimeZone, moisture,
      temperature, imageUrl, description);

  test('fromMap', () {
    LinkedHashMap entriesWithNull =
        LinkedHashMap.from(Map.fromIterables([null, "valid id"], [null, null]));
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
      Plant('', 'some name', '', 0, 0, 0, '', ''),
      Plant('', name, '', 0, 0, 0, '', '')
    ],
        doesNotContainDuplicateName = [
      testPlant,
      Plant('', 'some name', '', 0, 0, 0, '', ''),
      Plant('', 'some name 2', '', 0, 0, 0, '', ''),
    ];

    expect(Plant.hasDuplicateName(plantId, name, containsDuplicateName), true);
    expect(Plant.hasDuplicateName(plantId, name, doesNotContainDuplicateName),
        false);
  });

  test('jsonDecode', () {

    String description = "\"\"\"\"\"\""
        .replaceAll("\n", "\\n")
        .replaceAll('\"', '\\"');
        // .replaceAll("'", "\'");

    String json = '{"name": "$description"}';
    // print(description);
    print(json);
    print(jsonDecode(json));
    // print(jsonDecode('{"id":"abcd\\nabcd"}')['id']);
  });
}
