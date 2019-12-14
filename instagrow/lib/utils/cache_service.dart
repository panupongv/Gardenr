import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagrow/models/dashboard_plant.dart';
import 'package:instagrow/utils/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static Future<void> _savePlants(String pathOption, List<DashBoardPlant> plants) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    FirebaseUser user = await AuthService.getUser();
    List<String> ids =
        plants.map((DashBoardPlant plant) => plant.id.toString()).toList();
    print(ids.toString());
    preferences.setStringList("${user.uid}/${pathOption}/IDS", ids);
    plants.forEach((DashBoardPlant plant) {
      preferences.setString("${user.uid}/${pathOption}/CACHE/${plant.id}", plant.toJson().toString());
    });
  }

  static Future<List<DashBoardPlant>> _loadPlants(String pathOption) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    FirebaseUser user = await AuthService.getUser();
    List<String> ids = preferences.getStringList("${user.uid}/${pathOption}/IDS");
    print("LOAD SP: "+ids.toString());
    if (ids == null) {
      return [];
    }
    List<DashBoardPlant> plants = [];
    ids.forEach((String plantId) {
      String jsonString = preferences.getString("${user.uid}/${pathOption}/CACHE/${plantId}") ?? null;
      if (jsonString != null) {
        Map plantJson = jsonDecode(jsonString);
        DashBoardPlant plant = DashBoardPlant.fromJson(plantJson);
        plants.add(plant);
      }
    });
    return plants;
  }

  static Future<void> saveMyPlants(List<DashBoardPlant> plants) async {
    _savePlants("MYPLANTS", plants);
  }

  static Future<List<DashBoardPlant>> loadMyPlants() async {
    return _loadPlants("MYPLANTS");
  }
}
