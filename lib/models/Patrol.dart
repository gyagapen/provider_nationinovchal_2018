class Patrol {
  String id = "";
  String description = "";
  String deviceId = "";
  String providerType = "";
  String token = "";
  String mobileNumber = "";
  String stationId = "";

  Patrol(
      {this.id,
      this.description,
      this.deviceId,
      this.providerType,
      this.token,
      this.mobileNumber,
      this.stationId});

  factory Patrol.fromJson(Map<String, dynamic> json) {
    return Patrol(
        id: json['id'],
        description: json['description'],
        deviceId: json['device_id'],
        providerType: json['service_provider_id'],
        token: json["token"],
        mobileNumber: json["mobile_number"],
        stationId: json["station_id"]);
  }
}
