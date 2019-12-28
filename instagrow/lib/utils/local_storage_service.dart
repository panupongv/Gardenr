import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/utils/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static Future<void> _savePlants(String pathOption, List<Plant> plants) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    FirebaseUser user = await AuthService.getUser();
    List<String> ids =
        plants.map((Plant plant) => plant.id.toString()).toList();
    preferences.setStringList("${user.uid}/$pathOption/IDS", ids);
    plants.forEach((Plant plant) {
      preferences.setString("${user.uid}/$pathOption/CACHE/${plant.id}", plant.toJson().toString());
    });
  }

  static Future<List<Plant>> _loadPlants(String pathOption) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    FirebaseUser user = await AuthService.getUser();
    List<String> ids = preferences.getStringList("${user.uid}/$pathOption/IDS");
    if (ids == null) {
      return [];
    }
    List<Plant> plants = [];
    ids.forEach((String plantId) {
      String jsonString = preferences.getString("${user.uid}/$pathOption/CACHE/$plantId") ?? null;
      if (jsonString != null) {
        Map plantJson = jsonDecode(jsonString);
        Plant plant = Plant.fromJson(plantJson);
        plants.add(plant);
      }
    });
    return plants;
  }

  static Future<void> saveMyPlants(List<Plant> plants) async {
    _savePlants("MYPLANTS", plants);
  }

  static Future<List<Plant>> loadMyPlants() async {
    return _loadPlants("MYPLANTS");
  }

  static Future<void> saveFollowingPlants(List<Plant> plants) async {
    _savePlants("FOLLOWINGPLANTS", plants);
  }

  static Future<List<Plant>> loadFollowingPlants() async {
    return _loadPlants("FOLLOWINGPLANTS");
  }

}
