import 'dart:collection';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:instagrow/models/enums.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/models/qr_translator.dart';
import 'package:instagrow/models/sensor_data.dart';
import 'package:instagrow/models/user_profile.dart';
import 'package:instagrow/utils/auth_service.dart';
import 'package:instagrow/utils/local_storage_service.dart';
import 'package:image/image.dart' as imageUtils;
import 'package:instagrow/utils/size_config.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';

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

  static Stream<Event> userProfileStream(FirebaseUser user) {
    return _database.child('users').child(user.uid).onValue;
  }

  static Stream<Event> plantProfileStream(String plantId) {
    return _database.child('plants').child(plantId).onValue;
  }

  static Future<Plant> getPlantById(String plantId, DateTime refreshedTime) async {
    DataSnapshot snapshot =
        await _database.child('plants').child(plantId).once();
    if (snapshot != null && snapshot.value != null) {
      return Plant.fromQueryData(
          plantId, snapshot.value, refreshedTime);
    }
    return null;
  }

  static Future<Plant> getPublicPlantById(String plantId, DateTime refreshedTime) async {
    DataSnapshot privacySnapshot =
        await _database.child('plants').child(plantId).child('isPublic').once();
    if (privacySnapshot != null && privacySnapshot.value == true) {
      DataSnapshot plantSnapshot =
          await _database.child('plants').child(plantId).once();
      if (plantSnapshot != null && plantSnapshot.value != null) {
        return Plant.fromQueryData(
            plantId, plantSnapshot.value, refreshedTime);
      }
    }
    return null;
  }

  static Future<List<String>> getMyPlantIds() async {
    FirebaseUser user = await AuthService.getUser();
    return _getPlantIds('ownedPlants', user.uid);
  }

  static Future<List<Plant>> getMyPlants(DateTime refreshedTime) async {
    int waitDurationInSeconds = 8;
    // DataSnapshot dataSnapshot = await _database
    //     .child('plants')
    //     .orderByChild('ownerId')
    //     .equalTo(userId)
    //     .once()
    //     .timeout(Duration(seconds: waitDurationInSeconds),
    //         onTimeout: () => null);

    // if (dataSnapshot == null) {
    //   return await LocalStorageService.loadMyPlants();
    // } else if (dataSnapshot.value == null) {
    //   return [];
    // }
    List<Plant> plants = await _getPlantsHelper('ownedPlants', refreshedTime)
        .timeout(Duration(seconds: waitDurationInSeconds),
            onTimeout: () => null);

    if (plants == null) {
      return LocalStorageService.loadMyPlants();
    }

    LocalStorageService.saveMyPlants(plants);
    return plants;

    // List<Plant> plants = Plant.fromMap(dataSnapshot.value, refreshedTime);
    // LocalStorageService.saveMyPlants(plants);
    // return plants;
  }

  static Future<List<Plant>> getFollowingPlants(DateTime refreshedTime) async {
    final int waitDurationInSec = 8;
    List<Plant> plants = await _getPlantsHelper(
            'followingPlants', refreshedTime)
        .timeout(Duration(seconds: waitDurationInSec), onTimeout: () => null);

    if (plants == null) {
      return LocalStorageService.loadFollowingPlants();
    }

    LocalStorageService.saveFollowingPlants(plants);
    return plants;
  }

  static Future<List<Plant>> _getPlantsHelper(
      String path, DateTime refreshedTime) async {
    FirebaseUser user = await AuthService.getUser();
    String userId = user.uid;
    DataSnapshot plantIdsSnapshot =
        await _database.child(path).child(userId).once();
    if (plantIdsSnapshot == null || plantIdsSnapshot.value == null) return [];

    LinkedHashMap<dynamic, dynamic> plantIds = plantIdsSnapshot.value;

    List<Plant> plants = List();
    List<Future> futures = List();

    plantIds.forEach((_, plantId) {
      futures.add(_addQueriedPlantToList(plantId, plants, refreshedTime));
    });
    await Future.wait(futures);
    return plants;
  }

  static Future<void> _addQueriedPlantToList(
      String plantId, List<Plant> plants, DateTime refreshedTime) async {
    // DataSnapshot isPublicResult =
    //     await _database.child('plants').child(plantId).child('isPublic').once();
    // if (isPublicResult == null ||
    //     isPublicResult.value == null ||
    //     isPublicResult.value == false) {
    //   return;
    // }

    DataSnapshot queryResult =
        await _database.child('plants').child(plantId).once();
    if (queryResult == null || queryResult.value == null) {
      return;
    }
    plants.add(Plant.fromQueryData(plantId, queryResult.value, refreshedTime));
  }

  static Future<List<Plant>> getOtherUserPlants(
      String otherUserId, DateTime refreshedTime) async {
    int waitDurationInSeconds = 8;
    String queryKey = "${otherUserId}_true";
    DataSnapshot publicPlantsResult = await _database
        .child('plants')
        .orderByChild('ownerId_isPublic')
        .equalTo(queryKey)
        .once()
        .timeout(Duration(seconds: waitDurationInSeconds),
            onTimeout: () => null);

    if (publicPlantsResult != null && publicPlantsResult.value != null) {
      return Plant.fromMap(publicPlantsResult.value, refreshedTime);
    }
    return null;
  }

  static Future<List<String>> getOtherUserFollowingPlantIds(
      String userId) async {
    return _getPlantIds('followingPlants', userId);
  }

  static Future<List<String>> _getPlantIds(String path, String userId) async {
    DataSnapshot snapshot = await _database.child(path).child(userId).once();
    if (snapshot != null && snapshot.value != null) {
      LinkedHashMap<dynamic, dynamic> hashMap = snapshot.value;
      return hashMap.values.map((x) => x.toString()).toList();
    }
    return [];
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
      Plant plant, File selectedImage) async {
    String storagePath = "plantProfileImages/${plant.id}.png";

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
          .child(plant.id)
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

  static Future<void> updateOwnerId(Plant plant) async {
    FirebaseUser user = await AuthService.getUser();
    await _database
        .child('plants')
        .child(plant.id)
        .child('ownerId')
        .set(user.uid);
  }

  static Future<void> updatePlantName(Plant plant, String name) async {
    await _database.child('plants').child(plant.id).child('name').set(name);
  }

  static Future<void> updatePlantDescription(
      Plant plant, String description) async {
    await _database
        .child('plants')
        .child(plant.id)
        .child('description')
        .set(description);
  }

  static Future<void> updatePlantPrivacy(Plant plant, bool isPublic) async {
    FirebaseUser user = await AuthService.getUser();

    await _database
        .child('plants')
        .child(plant.id)
        .child('isPublic')
        .set(isPublic);

    await _database
        .child('plants')
        .child(plant.id)
        .child('ownerId_isPublic')
        .set("${user.uid}_$isPublic");
  }

  static Future<SensorData> getSensorData(String plantId, DateTime date) async {
    String dateString = Jiffy(date).format("yyyyMMdd");
    DataSnapshot dataSnapshot = await _database
        .child('sensorValues')
        .child(plantId)
        .child(dateString)
        .once();
    if (dataSnapshot != null && dataSnapshot.value != null) {
      return SensorData.fromMap(dataSnapshot.value);
    }
    return null;
  }

  static Future<UserProfile> getOtherUserProfile(String userId) async {
    DataSnapshot dataSnapshot =
        await _database.child('users').child(userId).once();
    if (dataSnapshot != null && dataSnapshot.value != null) {
      return UserProfile.fromQueryData(userId, dataSnapshot.value);
    }
    return null;
  }

  static Future<Tuple2<bool, String>> _checkPlantExistsInCollection(
      String plantId) async {
    FirebaseUser user = await AuthService.getUser();

    DataSnapshot dataSnapshot = await _database
        .child('followingPlants')
        .child(user.uid)
        .orderByValue()
        .equalTo(plantId)
        .once();
    if (dataSnapshot == null || dataSnapshot.value == null) {
      return Tuple2<bool, String>(false, null);
    }
    LinkedHashMap<dynamic, dynamic> pair = dataSnapshot.value;
    String reference = pair.keys.first;
    return Tuple2(true, reference);
  }

  static Future<bool> plantIsFollowed(Plant plant) async {
    Tuple2<bool, String> plantExist =
        await _checkPlantExistsInCollection(plant.id);
    return plantExist.item1;
  }

  static Future<bool> toggleFollowPlant(Plant targetPlant) async {
    FirebaseUser user = await AuthService.getUser();
    Tuple2<bool, String> existAndReference =
        await _checkPlantExistsInCollection(targetPlant.id);

    if (existAndReference.item1) {
      await _database
          .child('followingPlants')
          .child(user.uid)
          .child(existAndReference.item2)
          .remove();
      return false;
    } else {
      await _database
          .child('followingPlants')
          .child(user.uid)
          .push()
          .set(targetPlant.id);
      return true;
    }
  }

  static Future<Tuple2<QrScanResult, String>> claimWithQr(
      String scanned) async {
    List<String> decoded = QrTranslator.decodeQr(scanned);
    if (decoded != null && decoded.length == 3) {
      String plantId = decoded[0], key = decoded[1], hashValue = decoded[2];

      DataSnapshot newPlantSnapshot =
          await _database.child('plants').child(plantId).once();

      if (newPlantSnapshot != null && newPlantSnapshot.value != null) {
        FirebaseUser user = await AuthService.getUser();
        String plantOwner = newPlantSnapshot.value['ownerId'];
        if (plantOwner == null) {
          DataSnapshot qrCheck = await _database
              .child('qrInstances')
              .child(plantId)
              .child(key)
              .once();
          if (qrCheck != null && qrCheck.value == hashValue) {
            await _database
                .child('plants')
                .child(plantId)
                .child('ownerId')
                .set(user.uid);

            await _database
                .child('ownedPlants')
                .child(user.uid)
                .push()
                .set(plantId);

            return Tuple2(QrScanResult.Success, plantId);
          }
        } else if (plantOwner == user.uid) {
          return Tuple2(
              QrScanResult.IsYourPlant, "The plant is already yours.");
        } else {
          return Tuple2(QrScanResult.AlreadyHasOwner,
              "Seems like the plant is owned by someone else, would you like to follow it?");
        }
      }
    }

    return Tuple2(QrScanResult.InvalidQr,
        "Please make sure to scan a QR codes from valid sources.");
  }

  static Future<Tuple2<QrScanResult, String>> followWithQr(
      String scanned) async {
    List<String> decoded = QrTranslator.decodeQr(scanned);
    if (decoded != null && decoded.length == 3) {
      String plantId = decoded[0], key = decoded[1], hashValue = decoded[2];

      print(plantId);
      print(key);
      print(hashValue);

      DataSnapshot qrSearchResult =
          await _database.child('qrInstances').child(plantId).child(key).once();

      if (qrSearchResult != null && qrSearchResult.value == hashValue) {
        Tuple2<bool, String> alreadyFollowing =
            await _checkPlantExistsInCollection(plantId);
        if (alreadyFollowing.item1) {
          return Tuple2(QrScanResult.IsYourPlant,
              "The plant is already in your collection.");
        } else {
          FirebaseUser user = await AuthService.getUser();
          await _database
              .child('followingPlants')
              .child(user.uid)
              .push()
              .set(plantId);
          return Tuple2(
              QrScanResult.Success, "The plant is added to your collection.");
        }
      }
    }
    return Tuple2(QrScanResult.InvalidQr,
        "Please make sure to scan a QR codes from valid sources.");
  }

  static Future<String> getCurrentQrCode(Plant plant) async {
    DataSnapshot currentQr = await _database
        .child('qrInstances')
        .child(plant.id)
        .orderByKey()
        .limitToFirst(1)
        .once();

    if (currentQr != null && currentQr.value != null) {
      LinkedHashMap<dynamic, dynamic> hashMap = currentQr.value;
      return QrTranslator.encodeQr(plant, hashMap);
    }
    return await createQrInstance(plant);
  }

  static Future<String> createQrInstance(Plant plant) async {
    String hash = Jiffy(DateTime.now().toUtc()).format("yyyyMMddHHmmssms");
    await _database.child('qrInstances').child(plant.id).remove();
    await _database.child('qrInstances').child(plant.id).push().set(hash);
    DataSnapshot newInstance = await _database
        .child('qrInstances')
        .child(plant.id)
        .limitToFirst(1)
        .once();

    if (newInstance != null && newInstance.value != null) {
      LinkedHashMap<dynamic, dynamic> hashMap = newInstance.value;
      return QrTranslator.encodeQr(plant, hashMap);
    }
    return null;
  }
}
