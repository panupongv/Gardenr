import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:instagrow/models/user_profile.dart';

void main() {
  String id = "ID",
      name = "USERNAME",
      description = "DESCRIPTION",
      imageUrl = "IMAGEURL";

  test('fromQueryData', () {
    LinkedHashMap data = LinkedHashMap.fromIterables(
      ['name', 'description', 'imageUrl'],
      [name, description, imageUrl],
    );

    UserProfile userProfile = UserProfile.fromQueryData(id, data);

    expect(userProfile.id, id);
    expect(userProfile.name, name);
    expect(userProfile.description, description);
    expect(userProfile.imageUrl, imageUrl);
  });
}
