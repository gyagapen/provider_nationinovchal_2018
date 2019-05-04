import 'package:http/http.dart' as http;
import 'dart:async';

class ServiceHelpRequest {
  //static String serviceBaseUrl = "http://aroma.mu/webservices/mausafe/index.php/";
  //static String serviceBaseUrl = "http://10.19.3.49:8083/mausafe/index.php/";
  static String serviceBaseUrl = "http://192.168.0.107:8083/mausafe/index.php/";
  static String apiKey = "58eb50e1-f87b-44a7-a4be-dcccd71625eb";

  static Map<String, String> generateHeaders() {
    Map<String, String> headers = new Map<String, String>();
    headers["x-api-key"] = apiKey;

    return headers;
  }

  static Future<http.Response> retrieveLiveRequest(
      String providerType, String longitude, String latitude, String stationId) async {
    var response = http.get(
        serviceBaseUrl +
            'HelpRequest/retrievePendingRequestForProvider?service_provider_type=' +
            providerType +
            '&longitude=' +
            longitude +
            '&latitude=' +
            latitude+
            '&station_id='+
            stationId,
        headers: generateHeaders());

        return response;
  }

  static Future<http.Response> retrieveHelpRequest(String id) async {
    return http.get(
        serviceBaseUrl + 'HelpRequest?device_id=' + id + '&type=ALL',
        headers: generateHeaders());
  }


  static Future<http.Response> retrieveStations(String providerType) async {
    return http.get(
        serviceBaseUrl + 'Patrol/station?provider_type='+providerType,
        headers: generateHeaders());
  }

  static Future<http.Response> assignPatrol(
      String helpRequestId,
      String longitude,
      String latitude,
      String patrolId,
      String deviceId,
      String patrolType) async {
    Map<String, String> bodyRequest = new Map<String, String>();

    bodyRequest["help_request_id"] = helpRequestId;
    bodyRequest["patrol_id"] = patrolId;
    bodyRequest["longitude"] = longitude;
    bodyRequest["latitude"] = latitude;
    bodyRequest["device_id"] = deviceId;
    bodyRequest["patrol_type"] = patrolType;

    return http.post(serviceBaseUrl + 'Patrol/assign',
        headers: generateHeaders(), body: bodyRequest);
  }

  static Future<http.Response> cancelPatrolAssignment(
      String assignmentId) async {
    Map<String, String> bodyRequest = new Map<String, String>();

    bodyRequest["assignment_id"] = assignmentId;

    return http.post(serviceBaseUrl + 'Patrol/cancel',
        headers: generateHeaders(), body: bodyRequest);
  }

  static Future<http.Response> retrievePatrolRegistration(
      String deviceId) async {
    return http.get(
        serviceBaseUrl + 'Patrol/infoPerDeviceName?device_id=' + deviceId,
        headers: generateHeaders());
  }

  static Future<http.Response> registerPatrol(String desc, String deviceId,
      String token, String provider, String mobileNumber, String stationId) async {
    Map<String, String> bodyRequest = new Map<String, String>();

    bodyRequest["desc"] = desc;
    bodyRequest["device_id"] = deviceId;
    bodyRequest["token"] = token;
    bodyRequest["provider"] = provider;
    bodyRequest["mobile_number"] = mobileNumber;
    bodyRequest["station_id"] = stationId;

    return http.post(serviceBaseUrl + 'Patrol/registerPatrol',
        headers: generateHeaders(), body: bodyRequest);
  }

  static Future<http.Response> updatePatrolRegistration(String deviceId,
      String provider, String desc, String mobileNumber, String stationId) async {
    Map<String, String> bodyRequest = new Map<String, String>();

    bodyRequest["device_id"] = deviceId;
    bodyRequest["provider"] = provider;
    bodyRequest["description"] = desc;
    bodyRequest["mobile_number"] = mobileNumber;
    bodyRequest["station_id"] = stationId;

    return http.post(serviceBaseUrl + 'Patrol/updatePatrolRegistration',
        headers: generateHeaders(), body: bodyRequest);
  }

  static Future<http.Response> logPatrolArrival(
      String patrolID, String helpRequestID) async {
    Map<String, String> bodyRequest = new Map<String, String>();

    bodyRequest["patrol_id"] = patrolID;
    bodyRequest["help_request_id"] = helpRequestID;

    return http.post(serviceBaseUrl + 'Patrol/logPatrolArrival',
        headers: generateHeaders(), body: bodyRequest);
  }
}
