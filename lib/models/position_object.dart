import 'computed_distance.dart';

class PositionObject {
  String longitude;
  String latitude;
  String updateDateTime;
  ComputedDistance distance;

  PositionObject({this.longitude, this.latitude, this.updateDateTime});

  factory PositionObject.fromJson(Map<String, dynamic> json) {
    return PositionObject(
      longitude: json['longitude'],
      latitude: json['latitude'],
      updateDateTime: json['date_time'],
    );
  }
}
