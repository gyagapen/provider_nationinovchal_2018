import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'helpers/common.dart';
import 'dart:async';
import 'dialogs/localisation_dialog.dart';
import 'package:progress_hud/progress_hud.dart';
import 'models/help_request.dart';
import 'dialogs/dialog_error_webservice.dart';
import 'services/service_help_request.dart';

class RequestInfoPage extends StatefulWidget {
  RequestInfoPage({Key key, this.helpRequest}) : super(key: key);

  final HelpRequest helpRequest;

  @override
  _RequestInfoPageState createState() => new _RequestInfoPageState();
}

class _RequestInfoPageState extends State<RequestInfoPage>
    with WidgetsBindingObserver {
  ProgressHUD _progressHUD;
  bool _isAssigned = false;

  @override
  initState() {
    WidgetsBinding.instance.addObserver(this);

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
    var actionButtons = new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        new Container(
          padding: new EdgeInsets.fromLTRB(75.0, 5.0, 20.0, 5.0),
          child: _isAssigned
              ? new Text("")
              : new RaisedButton(
                  textColor: Colors.black,
                  child: new Text("Accept".toUpperCase()),
                  onPressed: () {
                    assignPatrol();
                  },
                ),
        ),
        new Container(
          padding: new EdgeInsets.fromLTRB(5.0, 5.0, 75.0, 5.0),
          child: new RaisedButton(
            disabledColor: Colors.black,
            child: new Text("Reject".toUpperCase()),
            onPressed: () {},
          ),
        ),
      ],
    );

    var mainWrapper = new Column(
      children: [
        buildHelpRequestCard(),
      ],
    );

    return new Scaffold(
      appBar: new AppBar(
        title: Common.generateAppTitleBar(),
      ),
      body: new Stack(children: [mainWrapper, _progressHUD]),
      persistentFooterButtons: [actionButtons],
      // This trailing comma makes auto-formatting nicer for build methods.
    );
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
    Common.getDeviceUID().then((uiD) {
      HelpRequest helpRequest = widget.helpRequest;
      ServiceHelpRequest
          .assignPatrol(helpRequest.id, Common.myLocation.longitude.toString(),
              Common.myLocation.latitude.toString(), Common.patrolID, uiD)
          .then((response) {
        if (response.statusCode == 200) {
          //ok
          print("assignment is ok");
        } else {
          showDataConnectionError(context, Common.wsUserError);
        }
      }).catchError((e) {
        showDataConnectionError(
            context, Common.wsTechnicalError + ": " + e.toString());
      });
    }).catchError((e) {
      showDataConnectionError(
          context, Common.wsTechnicalError + ": " + e.toString());
    });
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
