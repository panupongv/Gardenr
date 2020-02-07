import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  //
  //
  // Setup
  //
  //

  static final DatabaseReference _database =
      FirebaseDatabase.instance.reference();

  static final StorageReference _storage = FirebaseStorage.instance.ref();

  //
  //
  //
  // User Profile Management----------------------------------------------
  //
  //
  //

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

  static Future<void> updateProfileImage(File selectedImage) async {
    FirebaseUser user = await AuthService.getUser();
    String storagePath = "profileImages/${user.uid}.png";

    File resizedImageFile =
        await _resizedImage(selectedImage, PROFILE_TAB_IMAGE_SIZE.round());

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

  static Future<UserProfile> getOtherUserProfile(String userId) async {
    DataSnapshot dataSnapshot =
        await _database.child('users').child(userId).once();
    if (dataSnapshot != null && dataSnapshot.value != null) {
      return UserProfile.fromQueryData(userId, dataSnapshot.value);
    }
    return null;
  }

  //
  //
  //
  //
  // Plant Profile Management----------------------------------------------
  //
  //
  //

  static Stream<Event> plantProfileStream(String plantId) {
    return _database.child('plants').child(plantId).onValue;
  }

  static Future<void> updatePlantProfileImage(
      Plant plant, File selectedImage) async {
    String storagePath = "plantProfileImages/${plant.id}.png";

    File resizedImageFile =
        await _resizedImage(selectedImage, PROFILE_TAB_IMAGE_SIZE.round());

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
    await _database
        .child('plants')
        .child(plant.id)
        .child('isPublic')
        .set(isPublic);
  }

  //
  //
  //
  // Plant and id queries------------------------------------------------
  //
  //
  //

  static Future<List<Plant>> getMyPlants(DateTime refreshedTime) async {
    int queryAlgorithm = Random().nextInt(2);

    FirebaseUser user = await AuthService.getUser();
    int waitDurationInSeconds = 8;

    if (queryAlgorithm == 0) {
      Trace trace = FirebasePerformance.instance.newTrace('MyPlantsQuery');
      trace.putAttribute("QueryAlgorithm", "Without Index");
      trace.start();
      List<Plant> plants =
          await _getPlantsHelper('ownedPlants', user.uid, refreshedTime)
              .timeout(Duration(seconds: waitDurationInSeconds),
                  onTimeout: () => null);

      if (plants != null) {
        LocalStorageService.saveMyPlants(plants);

        trace.putAttribute("CollectionSize", plants.length.toString());
        trace.stop();
        return plants;
      }

      trace.stop();
      return await LocalStorageService.loadMyPlants();
    } else {
      Trace trace = FirebasePerformance.instance.newTrace('MyPlantsQuery');
      trace.putAttribute("QueryAlgorithm", "With Custom Index");
      trace.start();
      DataSnapshot snapshot = await _database
          .child('plants')
          .orderByChild('ownerId')
          .equalTo(user.uid)
          .once()
          .timeout(
            Duration(seconds: waitDurationInSeconds),
            onTimeout: () => null,
          );
      if (snapshot == null) {
        trace.stop();
        return await LocalStorageService.loadMyPlants();
      }

      List<Plant> plants = List();
      if (snapshot.value != null) {
        plants = Plant.fromMap(snapshot.value, refreshedTime);
        LocalStorageService.saveMyPlants(plants);
      }
      trace.putAttribute("CollectionSize", plants.length.toString());
      trace.stop();
      return plants;
    }
  }

  static Future<List<Plant>> getFollowingPlants(DateTime refreshedTime) async {
    Trace trace = FirebasePerformance.instance.newTrace('FollowingPlantsQuery');
    trace.start();
    FirebaseUser user = await AuthService.getUser();
    final int waitDurationInSec = 8;
    List<Plant> plants = await _getPlantsHelper(
            'followingPlants', user.uid, refreshedTime)
        .timeout(Duration(seconds: waitDurationInSec), onTimeout: () => null);

    if (plants == null) {
      return LocalStorageService.loadFollowingPlants();
    }

    LocalStorageService.saveFollowingPlants(plants);

    trace.putAttribute("CollectionSize", plants.length.toString());
    trace.stop();
    return plants;
  }

  static Future<List<Plant>> getOtherUserPlants(
      String userId, DateTime refreshedTime) async {
    Trace trace =
        FirebasePerformance.instance.newTrace('OtherUserGardenPlantsQuery');
    await trace.start();
    List<String> myFollowingPlantIds = await _getMyFollowingIds(),
        otherUserPlantIds = await _getOtherUserPlantIds(userId);

    List<Plant> results = await _otherUserCollectionHelper(
      otherUserPlantIds,
      myFollowingPlantIds,
      refreshedTime,
    );

    trace.putAttribute("CollectionSize", results.length.toString());
    trace.stop();
    return results;
  }

  static Future<List<Plant>> getOtherUserFollowingPlants(
      String userId, DateTime refreshedTime) async {
    Trace trace =
        FirebasePerformance.instance.newTrace('OtherUserFollowingPlantsQuery');
    trace.start();

    List<String> myPlantIds = await _getMyPlantIds(),
        myFollowingPlantIds = await _getMyFollowingIds(),
        otherUserFollowingPlantIds =
            await _getOtherUserFollowingPlantIds(userId);

    List<Plant> results = await _otherUserCollectionHelper(
      otherUserFollowingPlantIds,
      myPlantIds + myFollowingPlantIds,
      refreshedTime,
    );

    trace.putAttribute("CollectionSize", results.length.toString());
    trace.stop();
    return results;
  }

  static Future<List<Plant>> _getPlantsHelper(
      String path, String userId, DateTime refreshedTime) async {
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
    Plant plant = await _getPlantById(plantId, refreshedTime);
    if (plant == null) {
      return;
    }
    plants.add(plant);
  }

  static Future<List<String>> _getMyPlantIds() async {
    FirebaseUser user = await AuthService.getUser();
    return _getPlantIds('ownedPlants', user.uid);
  }

  static Future<List<String>> _getMyFollowingIds() async {
    FirebaseUser user = await AuthService.getUser();
    return _getPlantIds('followingPlants', user.uid);
  }

  static Future<List<String>> _getOtherUserPlantIds(String userId) async {
    return _getPlantIds('ownedPlants', userId);
  }

  static Future<List<String>> _getOtherUserFollowingPlantIds(
      String userId) async {
    return _getPlantIds('followingPlants', userId);
  }

  static Future<List<Plant>> _otherUserCollectionHelper(List<String> plantIds,
      List<String> surelyVisibleIds, DateTime refreshedTime) async {
    List<Plant> results = List();
    List<Future> futures = List();
    plantIds.forEach((String plantId) {
      if (surelyVisibleIds.contains(plantId)) {
        futures.add(_addQueriedPlantToList(plantId, results, refreshedTime));
      } else {
        futures.add(() async {
          Plant nonPrivatePlant =
              await DatabaseService._getPublicPlantById(plantId, refreshedTime);
          if (nonPrivatePlant != null) {
            results.add(nonPrivatePlant);
          }
        }());
      }
    });

    await Future.wait(futures);
    return results;
  }

  static Future<List<String>> _getPlantIds(String path, String userId) async {
    DataSnapshot snapshot = await _database.child(path).child(userId).once();
    if (snapshot != null && snapshot.value != null) {
      LinkedHashMap<dynamic, dynamic> hashMap = snapshot.value;
      return hashMap.values.map((x) => x.toString()).toList();
    }
    return [];
  }

  static Future<Plant> _getPlantById(
      String plantId, DateTime refreshedTime) async {
    DataSnapshot snapshot =
        await _database.child('plants').child(plantId).once();
    if (snapshot != null && snapshot.value != null) {
      return Plant.fromQueryData(plantId, snapshot.value, refreshedTime);
    }
    return null;
  }

  static Future<Plant> _getPublicPlantById(
      String plantId, DateTime refreshedTime) async {
    DataSnapshot privacySnapshot =
        await _database.child('plants').child(plantId).child('isPublic').once();
    if (privacySnapshot != null && privacySnapshot.value == true) {
      DataSnapshot plantSnapshot =
          await _database.child('plants').child(plantId).once();
      if (plantSnapshot != null && plantSnapshot.value != null) {
        return Plant.fromQueryData(plantId, plantSnapshot.value, refreshedTime);
      }
    }
    return null;
  }

  static Future<SensorData> getSensorData(String plantId, DateTime date) async {
    Trace trace = FirebasePerformance.instance.newTrace('GetSensorData');
    trace.start();
    String dateString = Jiffy(date).format("yyyyMMdd");
    DataSnapshot dataSnapshot = await _database
        .child('sensorValues')
        .child(plantId)
        .child(dateString)
        .once();

    SensorData data;
    if (dataSnapshot != null && dataSnapshot.value != null) {
      LinkedHashMap hashMap = dataSnapshot.value;
      data = SensorData.fromMap(hashMap);
      trace.setMetric("HasActualSensorData", 1);
      trace.putAttribute("CollectionSize", hashMap.length.toString());
    } else {
      trace.setMetric("HasActualSensorData", 0);
    }
    trace.stop();
    return data;
  }

  //
  //
  //
  // Following Utilities
  //
  //
  //

  static Future<Tuple2<bool, String>> _checkPlantExistsInGarden(
      String plantId) async {
    return _checkExistHelper(plantId, 'ownedPlants');
  }

  static Future<Tuple2<bool, String>> _checkPlantExistsInCollection(
      String plantId) async {
    return _checkExistHelper(plantId, 'followingPlants');
  }

  static Future<Tuple2<bool, String>> _checkExistHelper(
      String plantId, String collectionPath) async {
    FirebaseUser user = await AuthService.getUser();

    DataSnapshot dataSnapshot = await _database
        .child(collectionPath)
        .child(user.uid)
        .orderByValue()
        .equalTo(plantId)
        .once();
    if (dataSnapshot == null || dataSnapshot.value == null) {
      return Tuple2(false, null);
    }
    LinkedHashMap<dynamic, dynamic> pair = dataSnapshot.value;
    if (pair.isEmpty) {
      return Tuple2(false, null);
    }
    String reference = pair.keys.first;
    return Tuple2(true, reference);
  }

  static Future<bool> plantIsFollowed(Plant plant) async {
    Tuple2<bool, String> plantExist =
        await _checkPlantExistsInCollection(plant.id);
    return plantExist.item1;
  }

  static Future<bool> toggleFollowPlant(Plant targetPlant) async {
    Trace trace = FirebasePerformance.instance.newTrace('ToggleFollowStatus');
    trace.start();

    FirebaseUser user = await AuthService.getUser();
    Tuple2<bool, String> existAndReference =
        await _checkPlantExistsInCollection(targetPlant.id);

    if (existAndReference.item1) {
      await _database
          .child('followingPlants')
          .child(user.uid)
          .child(existAndReference.item2)
          .remove();

      trace.putAttribute("Action", "Unfollow");
      trace.stop();
      return false;
    } else {
      await _database
          .child('followingPlants')
          .child(user.uid)
          .push()
          .set(targetPlant.id);

      trace.putAttribute("Action", "Follow");
      trace.stop();
      return true;
    }
  }

  //
  //
  //
  // QR Utilities
  //
  //
  //

  static Future<Tuple2<QrScanResult, String>> claimWithQr(
      String scanned) async {
    List<String> decoded = QrTranslator.decodeQr(scanned);
    if (decoded != null) {
      String plantId = decoded[0], key = decoded[1], hashValue = decoded[2];

      DataSnapshot newPlantSnapshot =
          await _database.child('plants').child(plantId).once();

      if (newPlantSnapshot != null && newPlantSnapshot.value != null) {
        FirebaseUser user = await AuthService.getUser();
        String plantOwner = newPlantSnapshot.value['ownerId'];
        if (plantOwner == null || plantOwner == "") {
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
    if (decoded != null) {
      String plantId = decoded[0], key = decoded[1], hashValue = decoded[2];

      DataSnapshot qrSearchResult =
          await _database.child('qrInstances').child(plantId).child(key).once();

      if (qrSearchResult != null && qrSearchResult.value == hashValue) {
        Tuple2 alreadyFollowing = await _checkPlantExistsInCollection(plantId);
        if (alreadyFollowing.item1) {
          return Tuple2(QrScanResult.IsYourPlant,
              "The plant is already in your collection.");
        }

        Tuple2 isMyPlant = await _checkPlantExistsInGarden(plantId);

        if (isMyPlant.item1) {
          return Tuple2(QrScanResult.IsYourPlant, "The plant is yours.");
        }

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
