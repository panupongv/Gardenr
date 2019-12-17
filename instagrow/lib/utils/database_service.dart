import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/dashboard_plant.dart';
import 'package:instagrow/utils/auth_service.dart';
import 'package:instagrow/utils/cache_service.dart';

class DatabaseService {
  static final DatabaseReference _database =
      FirebaseDatabase.instance.reference();

  static Future<void> createUserInstance(FirebaseUser newUser) async {
    String userId = newUser.uid;
    String trimmedEmail =
        newUser.email.toString().toLowerCase().split("@").elementAt(0);
    await _database.child("users").child(userId).set(<String, String>{
      "name": trimmedEmail,
    });
  }

  static Stream<Event> profileImageStream(FirebaseUser user) {
    return _database.child('users').child(user.uid).child('imageUrl').onValue;
  }

  static Stream<Event> displayNameStream(FirebaseUser user) {
    return _database.child('users').child(user.uid).child('name').onValue;
  }

  static Stream<Event> userDescriptionStream(FirebaseUser user) {
    return _database.child('users').child(user.uid).child('description').onValue;
  }

  static Future<List<DashBoardPlant>> getMyPlants(
      DateTime refreshedTime) async {
    String userId = (await AuthService.getUser()).uid;
    int waitDurationInSeconds = 3;
    DataSnapshot dataSnapshot = await _database
        .child('plants')
        .orderByChild('ownerId')
        .equalTo(userId)
        .once()
        .timeout(Duration(seconds: waitDurationInSeconds), onTimeout: () {
      return null;
    });

    if (dataSnapshot == null) {
      return await CacheService.loadMyPlants();
    }

    List<DashBoardPlant> plants =
        DashBoardPlant.fromMap(dataSnapshot.value, refreshedTime);
    CacheService.saveMyPlants(plants);
    return plants;
  }

  static Future<List<DashBoardPlant>> getFollowingPlants(
      DateTime refreshedTime) async {
    final int waitDurationInSec = 5;
    List<DashBoardPlant> plants = await _getFollowingPlants(refreshedTime)
        .timeout(Duration(seconds: waitDurationInSec), onTimeout: () {
      return null;
    });

    if (plants == null) {
      return CacheService.loadFollowingPlants();
    }

    CacheService.saveFollowingPlants(plants);
    return plants;
  }

  static Future<List<DashBoardPlant>> _getFollowingPlants(
      DateTime refreshedTime) async {
    FirebaseUser user = await AuthService.getUser();
    String userId = user.uid;
    DataSnapshot plantIdsSnapshot = await _database
        .child('users')
        .child(userId)
        .child('followingPlants')
        .once();
    if (plantIdsSnapshot == null) return [];

    List<dynamic> plantIds = plantIdsSnapshot.value;
    List<DashBoardPlant> plants = List();
    List<Future> futures = List();
    for (int plantId in plantIds) {
      futures.add(_addQueriedPlantToList(plantId, plants, refreshedTime));
    }
    await Future.wait(futures);
    return plants;
  }

  static Future<void> _addQueriedPlantToList(
      int plantId, List<DashBoardPlant> plants, DateTime refreshedTime) async {
    var queryResult =
        await _database.child('plants').child(plantId.toString()).once();
    if (queryResult == null) {
      return;
    }
    plants.add(DashBoardPlant.fromQueryData(
        plantId.toString(), queryResult.value, refreshedTime));
  }
}
