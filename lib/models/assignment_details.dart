class AssignmentDetails {
  String id;
  String helpRequestId;
  String patrolId;
  String etaMin;
  String distanceKm;
  String status;
  String serviceProviderType;
  String longitude;
  String latitude;

  AssignmentDetails(
      {this.id,
      this.helpRequestId,
      this.patrolId,
      this.etaMin,
      this.distanceKm,
      this.status,
      this.serviceProviderType,
      this.longitude,
      this.latitude});

  factory AssignmentDetails.fromJson(Map<String, dynamic> json) {
    return AssignmentDetails(
      id: json['id'],
      helpRequestId: json['help_request_id'],
      patrolId: json['patrol_id'],
      etaMin: json['ETA_min'],
      distanceKm: json['distance_km'],
      status: json['status'],
      serviceProviderType: json['service_provider_type'],
      longitude: json['longitude'],
      latitude: json['latitude'],
    );
  }
}
