import 'package:flutter/material.dart';
import '../models/custom_location.dart';
import 'dart:async';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart' show PlatformException;

class Common {
  static CustomLocation myLocation = new CustomLocation();
  static String wsTechnicalError =
      "Cannot contact MauSafe servers. Kindly ensure that you are connected to internet";
  static String wsUserError =
      "Error while sending request to MauSafe servers. Error Details: ";

  static String providerType = "SAMU";

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
  String deviceVersion;
  String identifier;
  final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
  try {
    var build = await deviceInfoPlugin.androidInfo;
    identifier = build.id;
    deviceName = build.model;
    deviceVersion = build.version.toString();
  } on PlatformException {
    print('Failed to get platform version');
  }

//if (!mounted) return;
  return identifier+"-"+deviceName;
}
}
