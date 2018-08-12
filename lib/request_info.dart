import 'package:flutter/material.dart';
import 'helpers/common.dart';
import 'package:progress_hud/progress_hud.dart';
import 'models/help_request.dart';
import 'dialogs/dialog_error_webservice.dart';
import 'services/service_help_request.dart';
import 'dart:convert';
import 'dialogs/dialog_cancel_request.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class RequestInfoPage extends StatefulWidget {
  RequestInfoPage({Key key, this.helpRequest, this.patrolAssignmentId})
      : super(key: key);

  final HelpRequest helpRequest;
  final String patrolAssignmentId;

  @override
  _RequestInfoPageState createState() => new _RequestInfoPageState();
}

class _RequestInfoPageState extends State<RequestInfoPage>
    with WidgetsBindingObserver {
  ProgressHUD _progressHUD;
  bool _isAssigned = false;
  String _assignmentId = "";

  @override
  initState() {
    WidgetsBinding.instance.addObserver(this);

    if (widget.patrolAssignmentId != "") {
      _isAssigned = true;
      _assignmentId = widget.patrolAssignmentId;
    }

    //initiate progress hud
    _progressHUD = new ProgressHUD(
      backgroundColor: Colors.black54,
      color: Colors.white,
      containerColor: Colors.black,
      borderRadius: 5.0,
      text: 'Loading...',
      loading: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    var notAssignedButtons = [
      new Container(
        padding: new EdgeInsets.fromLTRB(75.0, 5.0, 20.0, 5.0),
        child: new RaisedButton(
          textColor: Colors.white,
          color: Colors.green[700],
          child: new Row(
            children: [
              new Icon(Icons.tap_and_play),
              new Text("ACCEPT".toUpperCase()),
            ],
          ),
          onPressed: () {
            assignPatrol();
          },
        ),
      ),
      new Container(
        padding: new EdgeInsets.fromLTRB(5.0, 5.0, 50.0, 5.0),
        child: new RaisedButton(
          textColor: Colors.white,
          color: Colors.red[700],
          child: new Row(
            children: [
              new Icon(Icons.error),
              new Text("REJECT".toUpperCase()),
            ],
          ),
          onPressed: () {
            //pop back
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        ),
      ),
    ];

    var assignedButtons = [
      new Container(
        padding: new EdgeInsets.fromLTRB(5.0, 5.0, 25.0, 5.0),
        child: new RaisedButton(
          color: Colors.blue,
          textColor: Colors.white,
          disabledColor: Colors.black,
          child: new Row(
            children: [
              new Icon(Icons.navigation),
              new Text("Go".toUpperCase()),
            ],
          ),
          onPressed: () {
            String url = 'https://www.google.com/maps/dir/?api=1&destination=' +
                widget.helpRequest.latestPosition.latitude +
                ',' +
                widget.helpRequest.latestPosition.longitude +
                '&dir_action=navigate';
            launch(url);
          },
        ),
      ),
      new Container(
        padding: new EdgeInsets.fromLTRB(5.0, 5.0, 25.0, 5.0),
        child: new RaisedButton(
          color: Colors.green,
          textColor: Colors.white,
          disabledColor: Colors.black,
          child: new Row(
            children: [
              new Icon(Icons.call),
              new Text("CALL".toUpperCase()),
            ],
          ),
          onPressed: () {
            String url = 'tel:59807708';
            launch(url);
          },
        ),
      ),
      new Container(
        padding: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        child: new RaisedButton(
          color: Colors.red,
          textColor: Colors.white,
          disabledColor: Colors.black,
          child: new Row(
            children: [
              new Icon(Icons.cancel),
              new Text("CANCEL".toUpperCase()),
            ],
          ),
          onPressed: () {
            showCancelSPRequestDialog(context, callCancelHelpRequestWs);
          },
        ),
      ),
    ];

    var mainWrapper = new Column(
      children: [
        buildHelpRequestCard(),
      ],
    );

    return new WillPopScope(
        onWillPop: () {
          if (_isAssigned) {
            showCancelSPRequestDialog(context, callCancelHelpRequestWs);
          } else {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          }
        },
        child: new Scaffold(
          appBar: new AppBar(
            title: Common.generateAppTitleBar(),
          ),
          body: new Stack(children: [mainWrapper, _progressHUD]),
          persistentFooterButtons:
              _isAssigned ? assignedButtons : notAssignedButtons,
          // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }

  Card buildHelpRequestCard() {
    if (_progressHUD.state != null) {
      _progressHUD.state.dismiss();
    }

    HelpRequest helpRequest = widget.helpRequest;

    //build help request cards

    var spNameHeader = new Container(
        padding: new EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            new Container(
              padding: new EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
              child: helpRequest.eventIcon,
            ),
            new Text(
              helpRequest.eventType.toUpperCase(),
              style: new TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: helpRequest.eventIcon.color),
            ),
          ],
        ));

    var spGeneralInfoContent = new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        new Column(
          children: [
            //Title
            new Center(
              child: new Container(
                padding: new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                child: new Text(
                  "General Info",
                  style: new TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            //Name
            new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                new Container(
                    padding: new EdgeInsets.fromLTRB(40.0, 10.0, 25.0, 0.0),
                    child: new Text(
                      "Name: ",
                      style: new TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    )),
                new Container(
                    padding: new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    child: new Text(
                      helpRequest.name,
                      style: new TextStyle(color: Colors.black, fontSize: 15.0),
                    )),
              ],
            ),
            //NIC
            new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                new Container(
                    padding: new EdgeInsets.fromLTRB(40.0, 10.0, 25.0, 0.0),
                    child: new Text(
                      "ID No: ",
                      style: new TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    )),
                new Container(
                    padding: new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    child: new Text(
                      helpRequest.nic,
                      style: new TextStyle(color: Colors.black, fontSize: 15.0),
                    )),
              ],
            ),
            //Age
            new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                new Container(
                    padding: new EdgeInsets.fromLTRB(40.0, 10.0, 35.0, 0.0),
                    child: new Text(
                      "Age: ",
                      style: new TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    )),
                new Container(
                    padding: new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    child: new Text(
                      helpRequest.age,
                      style: new TextStyle(color: Colors.black, fontSize: 15.0),
                    )),
              ],
            ),
            //Blood group
            new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                new Container(
                    padding: new EdgeInsets.fromLTRB(40.0, 10.0, 60.0, 0.0),
                    child: new Text(
                      "Blood group: ",
                      style: new TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    )),
                new Container(
                    padding: new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    child: new Text(
                      helpRequest.bloodGroup,
                      style: new TextStyle(color: Colors.black, fontSize: 15.0),
                    )),
              ],
            ),
            //Special conditions
            new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                new Container(
                    padding: new EdgeInsets.fromLTRB(40.0, 10.0, 15.0, 10.0),
                    child: new Text(
                      "Special Conditions: ",
                      style: new TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    )),
                new Container(
                    padding: new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                    child: new Text(
                      helpRequest.specialConditions,
                      style: new TextStyle(color: Colors.black, fontSize: 15.0),
                    )),
              ],
            ),
          ],
        ),
      ],
    );

    var spLocationContent = new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          new Column(children: [
            //Title
            new Center(
              child: new Container(
                padding: new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 20.0),
                child: new Text(
                  "Location Info",
                  style: new TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ]),
          //Address
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              new Container(
                padding: new EdgeInsets.fromLTRB(40.0, 0.0, 10.0, 0.0),
                child: new Text(
                  "Address: ",
                  style: new TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              new Flexible(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      helpRequest.latestPosition.distance.originAddress,
                      style: new TextStyle(color: Colors.black, fontSize: 15.0),
                    )
                  ],
                ),
              ),
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              new Container(
                padding: new EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
                child: new Row(children: [
                  new Icon(Icons.hourglass_empty),
                  new Text(
                    helpRequest.latestPosition.distance.eTAmin,
                    style: new TextStyle(
                        fontStyle: FontStyle.italic, fontSize: 15.0),
                  ),
                ]),
              ),
              new Container(
                  padding: new EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
                  child: new Row(
                    children: [
                      new Icon(Icons.drive_eta),
                      new Text(
                        helpRequest.latestPosition.distance.distanceKm,
                        style: new TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 15.0),
                      ),
                    ],
                  ))
            ],
          )
        ]);

    var spCard = new Card(
        margin: new EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
        child: new Container(
          width: 350.0,
          height: 450.0,
          child: new Column(children: [
            spNameHeader,
            new Divider(
              color: Colors.black45,
            ),
            spGeneralInfoContent,
            new Divider(
              color: Colors.black45,
            ),
            spLocationContent
          ]),
        ));

    return spCard;
  }

  void assignPatrol() {
    //show loading dialog
    if ((_progressHUD.state != null)) {
      _progressHUD.state.show();
    }

    Common.getDeviceUID().then((uiD) {
      HelpRequest helpRequest = widget.helpRequest;
      ServiceHelpRequest
          .assignPatrol(
              helpRequest.id,
              Common.myLocation.longitude.toString(),
              Common.myLocation.latitude.toString(),
              Common.patrolID,
              uiD,
              Common.providerType)
          .then((response) {
        //dismiss loading dialog
        if ((_progressHUD.state != null)) {
          _progressHUD.state.dismiss();
        }

          if (response.statusCode == 200) {
            Map<String, dynamic> decodedResponse = json.decode(response.body);
            if (decodedResponse["status"] == true) {
              //ok
            print("assignment is ok");
            _assignmentId = decodedResponse["id"].toString();
            setState(() {
              _isAssigned = true;
            });
          } else {
            showDataConnectionError(
                context, Common.wsUserError + decodedResponse["error"]);
          }
        } else {
          showDataConnectionError(context, Common.wsUserError);
        }
      }).catchError((e) {
        //dismiss loading dialog
        if ((_progressHUD.state != null)) {
          _progressHUD.state.dismiss();
        }
        showDataConnectionError(
            context, Common.wsTechnicalError + ": " + e.toString());
      });
    }).catchError((e) {
      //dismiss loading dialog
      if ((_progressHUD.state != null)) {
        _progressHUD.state.dismiss();
      }
      showDataConnectionError(
          context, Common.wsTechnicalError + ": " + e.toString());
    });
  }

  //call web service to perform cancellation of help request
  void callCancelHelpRequestWs() {
    if (_progressHUD.state != null) {
      _progressHUD.state.show();
    }

    ServiceHelpRequest.cancelPatrolAssignment(_assignmentId).then((response) {
      cancelWsCallback(response);
    });
  }

  void cancelWsCallback(http.Response response) {
    try {
      if (_progressHUD.state != null) {
        _progressHUD.state.dismiss();
      }
      if (response.statusCode == 200) {
        Map<String, dynamic> decodedResponse = json.decode(response.body);
        if (decodedResponse["status"] == true) {
          //pop back
          Navigator.popUntil(context, ModalRoute.withName('/'));
        } else {
          //show error dialog
          showDataConnectionError(
              context, Common.wsUserError, decodedResponse["error"]);
        }
      } else {
        //show error dialog
        showDataConnectionError(context, Common.wsTechnicalError);
      }
    } catch (e) {
      showDataConnectionError(
          context, Common.wsTechnicalError + ": " + e.toString());
    }
  }

  /****** Handle activity states **********/

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("state has changed: " + state.toString());
    setState(() {});
  }
}
