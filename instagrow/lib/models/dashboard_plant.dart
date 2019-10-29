class DashBoardPlant {
  String name;
  int timeUpdated, moisture, temperature;

  static DashBoardPlant fromQueryData(data) {
    var dataMap = data[1];
    DashBoardPlant newPlant = DashBoardPlant();
    newPlant.name = dataMap['name'];
    newPlant.timeUpdated = dataMap['timeUpdated'];
    newPlant.moisture = dataMap['moisture'];
    newPlant.temperature = dataMap['temperature'];
    return newPlant;
  }

  DashBoardPlant({
    this.name,
    this.timeUpdated,
    this.moisture,
    this.temperature
  });
}