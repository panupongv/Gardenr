import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:instagrow/models/dashboard_plant.dart';

class DatabaseService {
  static final DatabaseReference _database =
      FirebaseDatabase.instance.reference();

  static Future<void> createUserInstance(FirebaseUser newUser) async {
    String userId = newUser.uid;
    String userEmail =
        newUser.email.toString().toLowerCase().split("@").elementAt(0);
    await _database.child("users").child(userId).set(<String, String>{
      "name": userEmail,
    });
  }

  static Future<List<DashBoardPlant>> getMyPlants(FirebaseUser user, DateTime refreshedTime) async {
    String userId = user.uid;
    var queryResult = await _database.child('plants').orderByChild('ownerId').equalTo(userId).once();
    if (queryResult == null) {
      return [];
    }
    return DashBoardPlant.fromMap(queryResult.value, refreshedTime);
  }

  static Future<void> _queryFollowingPlant(int plantId, List<DashBoardPlant> plants, DateTime refreshedTime) async {
    var queryResult = await _database.child('plants').child(plantId.toString()).once();
    if (queryResult == null) {
      return;
    }
    plants.add(DashBoardPlant.fromQueryData(plantId.toString(), queryResult.value, refreshedTime));
  }

  static Future<List<DashBoardPlant>> getFollowingPlants(FirebaseUser user, DateTime refreshedTime) async {
    String userId = user.uid;
    var plantIdsQueryResult = await _database.child('users').child(userId).child('followingPlants').once();
    if (plantIdsQueryResult == null) return [];
    List<dynamic> plantIds = plantIdsQueryResult.value;
    List<DashBoardPlant> plants = List();
    List<Future> futures = List();
    for (int plantId in plantIds) {
      futures.add(_queryFollowingPlant(plantId, plants, refreshedTime));
    }
    await Future.wait(futures);
    return plants;
  }
}
