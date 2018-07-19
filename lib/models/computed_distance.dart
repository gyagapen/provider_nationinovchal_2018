class ComputedDistance {
  String distanceKm;
  String eTAmin;

  ComputedDistance({this.distanceKm, this.eTAmin});

  factory ComputedDistance.fromJson(Map<String, dynamic> json) {
    return ComputedDistance(
      distanceKm: json['distance'],
      eTAmin: json['time']
    );
  }
}
