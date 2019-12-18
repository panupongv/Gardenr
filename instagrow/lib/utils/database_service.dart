import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagrow/models/dashboard_plant.dart';
import 'package:instagrow/utils/auth_service.dart';
import 'package:instagrow/utils/dimension_config.dart';
import 'package:instagrow/utils/local_storage_service.dart';
import 'package:image/image.dart' as imageUtils;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class DatabaseService {
  static final DatabaseReference _database =
      FirebaseDatabase.instance.reference();

  static final StorageReference _storage = FirebaseStorage.instance.ref();

  static Future<void> createUserInstance(FirebaseUser newUser) async {
    String userId = newUser.uid;
    String trimmedEmail =
        newUser.email.toString().toLowerCase().split("@").elementAt(0);
    await _database.child("users").child(userId).set(<String, String>{
      "name": trimmedEmail,
    });
  }

  // static Stream<Event> profileImageStream(FirebaseUser user) {
  //   return _storage.child('profileImages').getStorage()
  //   return _database.child('users').child(user.uid).child('imageUrl').onValue;
  // }

  static Stream<Event> displayNameStream(FirebaseUser user) {
    return _database.child('users').child(user.uid).child('name').onValue;
  }

  static Stream<Event> userDescriptionStream(FirebaseUser user) {
    return _database
        .child('users')
        .child(user.uid)
        .child('description')
        .onValue;
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
      return await LocalStorageService.loadMyPlants();
    }

    List<DashBoardPlant> plants =
        DashBoardPlant.fromMap(dataSnapshot.value, refreshedTime);
    LocalStorageService.saveMyPlants(plants);
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
      return LocalStorageService.loadFollowingPlants();
    }

    LocalStorageService.saveFollowingPlants(plants);
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

  static Future<void> updateProfileImage(File selectedImage) async {
    imageUtils.Image tempImage =
        imageUtils.decodeImage(selectedImage.readAsBytesSync());
    imageUtils.Image resizedImage = imageUtils.copyResize(tempImage,
        width: PROFILE_IMAGE_SIZE.round(), height: PROFILE_IMAGE_SIZE.round());

    FirebaseUser user = await AuthService.getUser();
    String storagePath = "profileImages/${user.uid}.png";
    Directory tempDir = await getTemporaryDirectory();
    String tempLocalPath = tempDir.path;

    List<int> pngBytes = imageUtils.encodePng(resizedImage);
    File resizedImageFile = File("$tempLocalPath/temp.png");
    resizedImageFile.writeAsBytesSync(pngBytes);

    _storage.child(storagePath).putFile(resizedImageFile);
  }

  static Future<String> getProfileImageUrl(FirebaseUser user) async {
    try {
      String url = await _storage.child('profileImages').child('${user.uid}.png').getDownloadURL();
      print(">>"+url);
      return url;
    } on PlatformException catch (_) {}
    return null;
  }

  static Future<void> updateDisplayName(String name) async {
    FirebaseUser user = await AuthService.getUser();
    await _database.child('users').child(user.uid).child('name').set(name);
  }

  static Future<void> updateDescription(String description) async {
    FirebaseUser user = await AuthService.getUser();
    await _database.child('users').child(user.uid).child('description').set(description);
  }
}
