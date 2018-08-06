class ComputedDistance {
  String distanceKm = "Undefined";
  String eTAmin = "Undefined";
  String originAddress = "Undefined blank";
  String destinationAddress = "Undefined";

  ComputedDistance(
      {this.distanceKm,
      this.eTAmin,
      this.originAddress,
      this.destinationAddress});

  factory ComputedDistance.fromJson(Map<String, dynamic> json) {
    return ComputedDistance(
      distanceKm: json['distance'],
      eTAmin: json['time'],
      originAddress: json['origin_address'],
      destinationAddress: json['destination_address'],
    );
  }
}
