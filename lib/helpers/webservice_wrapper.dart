import 'dart:convert';
import '../services/service_help_request.dart';
import '../models/help_request.dart';
import '../models/station.dart';
import 'common.dart';

class WebserServiceWrapper {

  static void getPendingHelpRequestForProvider(String providerType,
      String longitude, String latitude, String stationId, bool firstCall, callback) {
    //try {
      //call webservice to check if any live request
      ServiceHelpRequest
          .retrieveLiveRequest(providerType, longitude, latitude, stationId)
          .then((response) {
        List<HelpRequest> helpRequestList = new List<HelpRequest>();

        if (response.statusCode == 200) {
          Map<String, dynamic> decodedResponse = json.decode(response.body);
          if (decodedResponse["status"] == true) {
            if (decodedResponse["help_details"] == null) {
              //no pending help request
              callback(null, null, firstCall);
            } else {
              //build list of help request
              for (var helpRequestJson in decodedResponse["help_details"]) {
                HelpRequest helpRequest = HelpRequest.fromJson(helpRequestJson);
                helpRequestList.add(helpRequest);
              }

              callback(helpRequestList, null, firstCall);
            }
          }
        } else {
          var ex = new Exception(Common.wsTechnicalError);
          throw ex;
        }
        });
      /*}).catchError((e) {
        throw e;
        callback(null, e, firstCall);
      });
    } catch (e) {
      throw e;
      callback(null, e, firstCall);
    }*/
  }


  static void getStations(String providerType, callback, {bool initCall = false})
  {
    List<Station> stations = new List<Station>();
    try {
          ServiceHelpRequest
          .retrieveStations(providerType)
          .then((response) {
            if (response.statusCode == 200) {
              Map<String, dynamic> decodedResponse = json.decode(response.body);
              if (decodedResponse["station"] != null) {
                  //build list of stations
                  for (var stationJson in decodedResponse["station"]) {
                    Station station = Station.fromJson(stationJson);
                    stations.add(station);
                  }
                  callback(stations, null, initCall);
              }   
            } else{
                callback(null, null, initCall);
            }

              
          }).catchError((e){
              callback(null, e, initCall);
              throw e;
          });
      }
      catch(e){
        callback(null, e, initCall);
        throw e;
      }
  }
  
}
