import 'package:hello_flutter/models/location_fact.dart';

class Location {
  final String name;
  final String url;
  final List<LocationFact> facts;
  Location({this.name, this.url, this.facts});
}