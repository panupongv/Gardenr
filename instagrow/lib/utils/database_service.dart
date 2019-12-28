import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagrow/models/plant.dart';
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
    _database
        .child('users')
        .child(userId)
        .set(<String, String>{"name": trimmedEmail});
    _database.child('users').child(userId).child("description").set("");
    _database.child('users').child(userId).child("imageUrl").set("");
  }

  static Stream<Event> profileImageStream(FirebaseUser user) {
    return _database.child('users').child(user.uid).child('imageUrl').onValue;
  }

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

  static Stream<Event> plantProfileStream(String plantId) {
    return _database.child('plants').child(plantId).onValue;
  }

  static Future<List<Plant>> getMyPlants(DateTime refreshedTime) async {
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

    if (dataSnapshot == null || dataSnapshot.value == null) {
      return await LocalStorageService.loadMyPlants();
    }

    List<Plant> plants = Plant.fromMap(dataSnapshot.value, refreshedTime);
    LocalStorageService.saveMyPlants(plants);
    return plants;
  }

  static Future<List<Plant>> getFollowingPlants(DateTime refreshedTime) async {
    final int waitDurationInSec = 5;
    List<Plant> plants = await _getFollowingPlants(refreshedTime)
        .timeout(Duration(seconds: waitDurationInSec), onTimeout: () {
      return null;
    });

    if (plants == null) {
      return LocalStorageService.loadFollowingPlants();
    }

    LocalStorageService.saveFollowingPlants(plants);
    return plants;
  }

  static Future<List<Plant>> _getFollowingPlants(DateTime refreshedTime) async {
    FirebaseUser user = await AuthService.getUser();
    String userId = user.uid;
    DataSnapshot plantIdsSnapshot = await _database
        .child('users')
        .child(userId)
        .child('followingPlants')
        .once();
    if (plantIdsSnapshot == null || plantIdsSnapshot.value == null) return [];

    List<dynamic> plantIds = plantIdsSnapshot.value;
    print("IDs: " + plantIds.toString());
    List<Plant> plants = List();
    List<Future> futures = List();
    for (String plantId in plantIds) {
      print(plantId);
      futures.add(_addQueriedPlantToList(plantId, plants, refreshedTime));
    }
    await Future.wait(futures);
    return plants;
  }

  static Future<void> _addQueriedPlantToList(
      String plantId, List<Plant> plants, DateTime refreshedTime) async {
    DataSnapshot queryResult =
        await _database.child('plants').child(plantId).once();
    if (queryResult == null || queryResult.value == null) {
      return;
    }
    print("xxx " + queryResult.value.toString());
    plants.add(Plant.fromQueryData(plantId, queryResult.value, refreshedTime));
  }

  static Future<void> updateProfileImage(File selectedImage) async {
    FirebaseUser user = await AuthService.getUser();
    String storagePath = "profileImages/${user.uid}.png";

    File resizedImageFile =
        await _resizedImage(selectedImage, PROFILE_IMAGE_SIZE.round());

    _storage
        .child(storagePath)
        .putFile(resizedImageFile)
        .onComplete
        .then((StorageTaskSnapshot snapshot) async {
      String imageUrl = await _storage.child(storagePath).getDownloadURL();
      await _database
          .child('users')
          .child(user.uid)
          .child('imageUrl')
          .set(imageUrl);
    });
  }

  static Future<void> updatePlantProfileImage(
      String plantId, File selectedImage) async {
    String storagePath = "plantProfileImages/$plantId.png";

    File resizedImageFile =
        await _resizedImage(selectedImage, PROFILE_IMAGE_SIZE.round());

    _storage
        .child(storagePath)
        .putFile(resizedImageFile)
        .onComplete
        .then((StorageTaskSnapshot snapshot) async {
      String imageUrl = await _storage.child(storagePath).getDownloadURL();
      await _database
          .child('plants')
          .child(plantId)
          .child('imageUrl')
          .set(imageUrl);
    });
  }

  static Future<File> _resizedImage(File originalImage, int size) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempFilePath = "${tempDir.path}/temp.png";
    File resizedImageFile = File(tempFilePath);

    imageUtils.Image tempImage =
        imageUtils.decodeImage(originalImage.readAsBytesSync());
    imageUtils.Image resizedImage =
        imageUtils.copyResize(tempImage, width: size, height: size);

    List<int> pngBytes = imageUtils.encodePng(resizedImage);
    resizedImageFile.writeAsBytesSync(pngBytes);

    return resizedImageFile;
  }

  // static Future<String> getProfileImageUrl(FirebaseUser user) async {
  //   try {
  //     String url = await _storage
  //         .child('profileImages')
  //         .child('${user.uid}.png')
  //         .getDownloadURL();
  //     return url;
  //   } on PlatformException catch (_) {}
  //   return null;
  // }

  static Future<void> updateDisplayName(String name) async {
    FirebaseUser user = await AuthService.getUser();
    await _database.child('users').child(user.uid).child('name').set(name);
  }

  static Future<void> updateDescription(String description) async {
    FirebaseUser user = await AuthService.getUser();
    await _database
        .child('users')
        .child(user.uid)
        .child('description')
        .set(description);
  }

  static Future<void> updatePlantName(String plantId, String name) async {
    await _database.child('plants').child(plantId).child('name').set(name);
  }

  static Future<void> updatePlantDescription(
      String plantId, String description) async {
    await _database
        .child('plants')
        .child(plantId)
        .child('description')
        .set(description);
  }
}
