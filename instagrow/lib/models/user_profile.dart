import 'dart:collection';

class UserProfile {
  final String _id, _name, _description, _imageUrl;
  UserProfile(this._id, this._name, this._description, this._imageUrl);

  String get id {
    return _id;
  }

  String get name {
    return _name;
  }

  String get description {
    return _description;
  }

  String get imageUrl {
    return _imageUrl;
  }

  factory UserProfile.fromQueryData(String id, LinkedHashMap dataMap) {
    return UserProfile(id, dataMap['name'], dataMap['description'], dataMap['imageUrl']);
  }
}
