import 'assignment_details.dart';
import 'assignment_details.dart';

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
      this.assignments});

  factory HelpRequest.fromJson(Map<String, dynamic> json) {
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
    );

    String requestedProvidersStr = json['requested_providers'];
    if (requestedProvidersStr.endsWith('|')) {
      requestedProvidersStr =
          requestedProvidersStr.substring(0, requestedProvidersStr.length - 1);
    }
    helpRequest.requestedServiceProviders = requestedProvidersStr.split('|');

    return helpRequest;
  }
}
