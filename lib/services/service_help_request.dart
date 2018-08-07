import 'package:http/http.dart' as http;
import 'dart:async';

class ServiceHelpRequest {
  //static String serviceBaseUrl = "http://aroma.mu/webservices/mausafe/index.php/";
  static String serviceBaseUrl = "http://192.168.0.105:8083/mausafe/index.php/";
  static String apiKey = "58eb50e1-f87b-44a7-a4be-dcccd71625eb";

  static Map<String, String> generateHeaders() {
    Map<String, String> headers = new Map<String, String>();
    headers["x-api-key"] = apiKey;

    return headers;
  }

  static Future<http.Response> retrieveLiveRequest(
      String providerType, String longitude, String latitude) async {
    return http.get(
        serviceBaseUrl +
            'HelpRequest/retrievePendingRequestForProvider?service_provider_type=' +
            providerType +
            '&longitude=' +
            longitude +
            '&latitude=' +
            latitude,
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
    bodyRequest ["latitude"] = latitude;
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
}
