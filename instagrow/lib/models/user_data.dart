import 'dart:collection';

class UserData {
  String displayName;
  List<int> followingPlantIds;

  UserData (this.displayName, this.followingPlantIds);

  static UserData fromMap (LinkedHashMap queryData) {
    return UserData("", []);
  }
}