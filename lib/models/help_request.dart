import 'assignment_details.dart';
import 'position_object.dart';

class HelpRequest {
  String id;
  String name;
  String nic;
  String age;
  String bloodGroup;
  String specialConditions;
  String deviceId;
  String deviceName;
  String status;
  String eventType;
  PositionObject latestPosition;
  List<AssignmentDetails> assignments;
  List<String> requestedServiceProviders;

  HelpRequest(
      {this.id,
      this.name,
      this.nic,
      this.age,
      this.bloodGroup,
      this.specialConditions,
      this.deviceId,
      this.deviceName,
      this.status,
      this.eventType,
      this.assignments,
      this.latestPosition});

  factory HelpRequest.fromJson(Map<String, dynamic> json) {
    PositionObject positionObject =
        PositionObject.fromJson(json['latest_position']);

    List<AssignmentDetails> assignmentDetails = new List<AssignmentDetails>();
    if (json['assignment_details'] != null) {
      for (var assignment in json['assignment_details']) {
        assignmentDetails.add(AssignmentDetails.fromJson(assignment));
      }
    }

    HelpRequest helpRequest = HelpRequest(
        id: json['id'],
        name: json['name'],
        nic: json['NIC'],
        age: json['age'],
        bloodGroup: json['blood_group'],
        specialConditions: json['special_conditions'],
        deviceId: json['device_id'],
        deviceName: json['device_name'],
        status: json['status'],
        eventType: json['event_type'],
        latestPosition: positionObject,
        assignments: assignmentDetails);

    String requestedProvidersStr = json['requested_providers'];
    if (requestedProvidersStr.endsWith('|')) {
      requestedProvidersStr =
          requestedProvidersStr.substring(0, requestedProvidersStr.length - 1);
    }
    helpRequest.requestedServiceProviders = requestedProvidersStr.split('|');

    return helpRequest;
  }
}
