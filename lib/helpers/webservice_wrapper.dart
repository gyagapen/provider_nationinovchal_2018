import 'dart:convert';
import '../services/service_help_request.dart';
import '../models/help_request.dart';
import '../models/assignment_details.dart';
import 'common.dart';

class WebserServiceWrapper {
  static void getPendingHelpRequestForProvider(
      String providerType, String longitude, String latitude, callback) {
    try {
      //call webservice to check if any live request
      ServiceHelpRequest
          .retrieveLiveRequest(providerType, longitude, latitude)
          .then((response) {
        if (response.statusCode == 200) {
          Map<String, dynamic> decodedResponse = json.decode(response.body);
          if (decodedResponse["status"] == true) {
            if (decodedResponse["help_details"] == null) {
              //no pending help request
              callback(null, null);
            } else {
              //build service providers as
              HelpRequest helpRequest =
                  HelpRequest.fromJson(decodedResponse["help_details"]);

              List<AssignmentDetails> assignmentDetails =
                  new List<AssignmentDetails>();
              if (decodedResponse["assignment_details"] != null) {
                for (var assignment in decodedResponse["assignment_details"]) {
                  assignmentDetails.add(AssignmentDetails.fromJson(assignment));
                }
              }
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
