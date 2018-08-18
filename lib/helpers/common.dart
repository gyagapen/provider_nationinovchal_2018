import 'package:flutter/material.dart';
import '../models/custom_location.dart';
import 'dart:async';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart' show PlatformException;
import '../models/Patrol.dart';
import 'package:flutter/services.dart';
import '../services/service_help_request.dart';
import '../models/help_request.dart';

class Common {
  static CustomLocation myLocation = new CustomLocation();
  static String wsTechnicalError =
      "Cannot contact MauSafe servers. Kindly ensure that you are connected to internet";
  static String wsUserError =
      "Error while sending request to MauSafe servers. Error Details: ";
  static String assigmentCancellationMsg =
      "Assignment has been cancelled by the requestor";
  static String assigmentAlreadyTakenMsg =
      "This request has been assigned to another patrol";
  static String assigmentError =
      "There has been a server error. Please contact Mausafe";

  static Patrol patrol;
  static String token;
  static String uID;
  static bool registrationJustCompleted = false;
  static List<HelpRequest> helpRequestList = new List<HelpRequest>();

  static String providerType = "SAMU";

  //frequency in ms to send updated location of patrol to server
  static String sendLocationIntervalMs = "60000";

  static Duration refreshListDuration = new Duration(seconds: 15);

  static String patrolID = "1";

  static Container generateAppTitleBar() {
    var appTitleBar = new Container(
        child: new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [
        new ImageIcon(
          AssetImage("images/general_logo.png"),
          size: 100.0,
        ),
        new Text(
          "Provider",
          style: new TextStyle(color: Colors.white),
        )
      ],
    ));

    return appTitleBar;
  }

  //get device UUID
  static Future<String> getDeviceUID() async {
    String deviceName;
    String deviceFingerprint;
    String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      var build = await deviceInfoPlugin.androidInfo;
      identifier = build.id;
      deviceName = build.model;
      deviceFingerprint = build.fingerprint;
    } on PlatformException {
      print('Failed to get platform version');
    }

//if (!mounted) return;
    return identifier + "-" + deviceName;
  }

  static String getServiceProviderTypeIcon(String providerType) {
    String imageProviderType = "images/applogo.png";

    switch (providerType) {
      case "SAMU":
        imageProviderType = "images/health.png";
        break;
      case "POLICE":
        imageProviderType = "images/policeman.png";
        break;
      case "FIREMAN":
        imageProviderType = "images/fireman.png";
        break;
    }

    return imageProviderType;
  }

  static Future<Null> startMausafeService(String helpRequestId) async {
    const platform = const MethodChannel('buildflutter.com/platform');
    int result = 0;
    try {
      result = await platform.invokeMethod('startMausafeService', {
        "patrolId": Common.patrolID,
        "helprequestId": helpRequestId,
        "intervalLocation": sendLocationIntervalMs,
        "urlEndPoint":
            ServiceHelpRequest.serviceBaseUrl + "Patrol/updatePatrolPosition",
        "xApiKey": ServiceHelpRequest.apiKey
      });
    } on PlatformException catch (e) {
      result = 0;
    }
  }

  static Future<Null> stopMausafeService() async {
    const platform = const MethodChannel('buildflutter.com/platform');
    int result = 0;
    try {
      result = await platform.invokeMethod('stopMausafeService');
    } on PlatformException catch (e) {
      result = 0;
    }
  }
}
