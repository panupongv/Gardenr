import 'dart:collection';
import 'package:timeago/timeago.dart' as TimeAgo;

class DashBoardPlant {
  String name, timeOffset;
  int id, moisture, temperature;

  static DashBoardPlant fromQueryData(id, data, refreshedTime) {
    DateTime timeData = DateTime.parse(data['timeUpdated']);
    //Duration offset = refreshedTime.difference(timeData);
    String timeAgo = TimeAgo.format(timeData, locale: 'en', clock: refreshedTime);
    return DashBoardPlant(int.parse(id), data['name'], timeAgo,
        data['moisture'], data['temperature']);
  }

  static List<DashBoardPlant> fromMap(LinkedHashMap map, DateTime refreshedTime) {
    //DateTime refreshedTime = DateTime.now().toUtc();
    List<DashBoardPlant> plants = List();
    //TimeAgo.setLocaleMessages('th', TimeAgo.ThMessages());

    map.forEach((k, v) {
      if (k != null && v != null)
        plants.add(DashBoardPlant.fromQueryData(k, v, refreshedTime));
    });
    
    return plants;
  }

  DashBoardPlant(
      this.id, this.name, this.timeOffset, this.moisture, this.temperature);
}
