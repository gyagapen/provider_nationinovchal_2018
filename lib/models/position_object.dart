
import 'computed_distance.dart';

class PositionObject {
  String longitude;
  String latitude;
  String updateDateTime;
  ComputedDistance distance;

  PositionObject({this.longitude, this.latitude, this.updateDateTime, this.distance});

  factory PositionObject.fromJson(Map<String, dynamic> json) {

    ComputedDistance computedDistance = ComputedDistance.fromJson(json['computed_distance']);

    return PositionObject(
      longitude: json['longitude'],
      latitude: json['latitude'],
      updateDateTime: json['date_time'],
      distance: computedDistance
    );
  }
}
