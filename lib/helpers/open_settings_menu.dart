import 'package:access_settings_menu/access_settings_menu.dart';
import 'dart:async';

class OpenSettings {
  // call the API function with settings name as parameter
  static Future<bool> GPSMenu() async {
    var resultSettingsOpening = false;

    try {
      resultSettingsOpening = await AccessSettingsMenu.openSettings(
          settingsType: "ACTION_LOCATION_SOURCE_SETTINGS");
    } catch (e) {
      resultSettingsOpening = false;
    }

    return resultSettingsOpening;
  }

// call the API function with settings name as parameter
  static Future<bool> WirelessMenu() async {
    var resultSettingsOpening = false;

    try {
      resultSettingsOpening = await AccessSettingsMenu.openSettings(
          settingsType: "ACTION_WIRELESS_SETTINGS");
    } catch (e) {
      resultSettingsOpening = false;
    }

    return resultSettingsOpening;
  }
}
