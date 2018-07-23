import 'dart:convert';
import '../services/service_help_request.dart';
import '../models/help_request.dart';
import '../models/assignment_details.dart';
import '../models/position_object.dart';
import 'common.dart';

class WebserServiceWrapper {
  static void getPendingHelpRequestForProvider(
      String providerType, String longitude, String latitude, callback) {
    try {
      //call webservice to check if any live request
      ServiceHelpRequest
          .retrieveLiveRequest(providerType, longitude, latitude)
          .then((response) {
        List<HelpRequest> helpRequestList = new List<HelpRequest>();

        if (response.statusCode == 200) {
          Map<String, dynamic> decodedResponse = json.decode(response.body);
          if (decodedResponse["status"] == true) {
            if (decodedResponse["help_details"] == null) {
              //no pending help request
              callback(null, null);
            } else {
              //build list of help request
              for (var helpRequestJson in decodedResponse["help_details"]) {
                HelpRequest helpRequest = HelpRequest.fromJson(helpRequestJson);
                helpRequestList.add(helpRequest);
              }

              callback(helpRequestList, null);
            }
          }
        } else {
          var ex = new Exception(Common.wsTechnicalError);
          throw ex;
        }
      }).catchError((e) {
        callback(null, e);
      });
    } catch (e) {
      callback(null, e);
    }
  }
}
