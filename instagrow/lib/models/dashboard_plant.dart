class DashBoardPlant {
  String name;
  int id, timeUpdated, moisture, temperature;

  static DashBoardPlant fromQueryData(id, data) {
    return DashBoardPlant(int.parse(id),
                          data['name'], 
                          data['timeUpdated'],
                          data['moisture'], 
                          data['temperature']);
  }

  DashBoardPlant(
      this.id, this.name, this.timeUpdated, this.moisture, this.temperature);
}
