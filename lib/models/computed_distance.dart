class ComputedDistance {
  String distanceKm = "Undefined";
  String eTAmin = "Undefined";

  ComputedDistance({this.distanceKm, this.eTAmin});

  factory ComputedDistance.fromJson(Map<String, dynamic> json) {
    return ComputedDistance(
      distanceKm: json['distance'],
      eTAmin: json['time']
    );
  }
}
