import 'package:flutter/material.dart';
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
  bool isWitness;
  String impactType;
  String buildingType;
  String noFloors;
  bool personTrapped;
  ImageIcon eventIcon;
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
      this.latestPosition,
      this.eventIcon,
      this.isWitness,
      this.impactType,
      this.buildingType,
      this.noFloors,
      this.personTrapped
      });

  factory HelpRequest.fromJson(Map<String, dynamic> json) {
    PositionObject positionObject;
    if (json['latest_position'] != null) {
      positionObject = PositionObject.fromJson(json['latest_position']);
    }

    List<AssignmentDetails> assignmentDetails = new List<AssignmentDetails>();
    if (json['assignment_details'] != null) {
      for (var assignment in json['assignment_details']) {
        assignmentDetails.add(AssignmentDetails.fromJson(assignment));
      }
    }

    ImageIcon imageIcon = HelpRequest.getIcon(json['event_type']);

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
        impactType: json['impact_type'],
        buildingType: json['building_type'],
        noFloors: json['no_floors'],
        personTrapped: json['person_trapped'] == "1",
        isWitness: json['is_witness'] == "1",
        eventIcon: imageIcon,
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

  static ImageIcon getIcon(String eventType) {
    ImageIcon iconImage = new ImageIcon(AssetImage("images/applogo.png"));

    switch (eventType) {
      case "Accident":
        iconImage = new ImageIcon(
          AssetImage("images/accident.png"),
          color: Colors.blue[500],
        );
        break;
      case "Health":
        iconImage = new ImageIcon(
          AssetImage("images/health.png"),
          color: Colors.red[500],
        );
        break;
      case "Assault":
        iconImage = new ImageIcon(
          AssetImage("images/assault.png"),
          color: Colors.green[500],
        );
        break;
      case "Fireman":
        iconImage = new ImageIcon(
          AssetImage("images/fire.png"),
          color: Colors.orange[500],
        );
        break;
      case "Thief":
        iconImage = new ImageIcon(
          AssetImage("images/thieft.png"),
          color: Colors.indigo[500],
        );

        break;
      case "Drowning":
        iconImage = new ImageIcon(
          AssetImage("images/drowning.png"),
          color: Colors.cyan[500],
        );
        break;
      case "Track me":
        iconImage = new ImageIcon(
          AssetImage("images/track_me.png"),
          color: Colors.lightGreen[500],
        );
        break;
    }

    return iconImage;
  }
}
