class Station {
  String id = "";
  String name = "";

  Station(
      {this.id,
      this.name});

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
        id: json['id'],
        name: json['station_name']);
  }
}
