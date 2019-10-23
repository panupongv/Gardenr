import '../models/location.dart';
import '../models/location_fact.dart';

class MockLocation extends Location {
  static FetchAny() {
    return Location(
      name:"Garden",
      url: "",
      facts: [
        LocationFact(title: "Summary", text: "yaydyadyaydyada"),
        LocationFact(title: "Direction", text: "Mike jones")
    );
  }
}