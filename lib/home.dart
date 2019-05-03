import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'helpers/common.dart';
import 'dart:async';
import 'dialogs/localisation_dialog.dart';
import 'package:progress_hud/progress_hud.dart';
import 'models/help_request.dart';
import 'helpers/webservice_wrapper.dart';
import 'dialogs/dialog_error_webservice.dart';
import 'request_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/service_help_request.dart';
import 'dart:convert';
import 'models/Patrol.dart';
import 'registration.dart';
import 'drawer.dart';
import 'dialogs/dialog_assignment_error.dart';
import 'package:flutter/services.dart';
import 'animations/waiting_text_animation.dart';
import 'package:flutter/animation.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  var _currentLocation = <String, double>{};
  bool _dataConnectionAvailable = true;
  bool _gpsPositionAvailable = true;
  bool _registrationNeeded = false;
  bool _pendingHelpRequest = false;

  ProgressHUD _progressHUD;
  List<HelpRequest> helpRequestDetails = new List<HelpRequest>();
  Timer refreshListTimer;

  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  AnimationController controller;
  Animation<double> animation;

  @override
  initState() {
    //Firebase Push notifs
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('on message $message');

        //play sound
        SystemSound.play(SystemSoundType.click);

        if (message["title"] == "CANCELLATION") {
          showAssignmentErrorDialog(context, Common.assigmentCancellationMsg);
        }
      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
      },
    );

    //register notification
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      print("token is" + token);
      Common.token = token;
      //check registration
      checkPatrolRegistration(context);
    }).catchError((e) {
      _dataConnectionAvailable = false;
      showDataConnectionError(
          context, Common.wsTechnicalError + ": " + e.toString());
    });

    WidgetsBinding.instance.addObserver(this);

    //initiate progress hud
    _progressHUD = new ProgressHUD(
      backgroundColor: Colors.black54,
      color: Colors.white,
      containerColor: Colors.black,
      borderRadius: 5.0,
      text: 'Loading...',
    );

    //animation
    controller = new AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = new Tween(begin: 0.0, end: 100.0).animate(controller);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });

    //launch animation
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    print("build widget called");

    if (Common.registrationJustCompleted) {
      Common.registrationJustCompleted = false;
      checkPatrolRegistration(context);
    }

    //photo
    var avatarCircle = new Center(
      child: new CircleAvatar(
        backgroundImage: new AssetImage(
            Common.getServiceProviderTypeIcon(Common.providerType)),
        backgroundColor: Colors.grey[300],
        radius: 50.0,
      ),
    );

    //name
    var nameHeader = new Container(
      padding: new EdgeInsets.all(5.0),
      height: 150.0,
      color: Colors.grey[300],
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          avatarCircle,
          new Text(
            Common.providerType + ' - Patrol ' + Common.patrolID,
            style: new TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );

    //waiting gif
    var waitingRequestGif = new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        new Container(
          padding: new EdgeInsets.fromLTRB(5.0, 30.0, 5.0, 5.0),
          child: new Image(
            image: new AssetImage("images/double_ring.gif"),
            width: 200.0,
            height: 200.0,
          ),
        ),
        new Container(
          padding: new EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 5.0),
          child: new AnimatedWaitingText(
            animation: animation,
          ),
        ),
      ],
    );

    var gpsErrorRetryWrapper = new Column(
      children: [
        nameHeader,
        new Container(
          padding: new EdgeInsets.fromLTRB(5.0, 150.0, 5.0, 5.0),
          child: new Text(
            "Error while getting your location",
            style: new TextStyle(
                color: Colors.red[900], fontWeight: FontWeight.bold),
          ),
        ),
        new Container(
          padding: new EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 5.0),
          child: new RaisedButton(
            child: new Text("Retry"),
            onPressed: () {
              getLocalisation(context);
            },
          ),
        )
      ],
    );

    var dataErrorRetryWrapper = new Column(
      children: [
        nameHeader,
        new Container(
          padding: new EdgeInsets.fromLTRB(5.0, 150.0, 5.0, 5.0),
          child: new Text(
            "Error while contacting MauSafe servers",
            style: new TextStyle(
                color: Colors.red[900], fontWeight: FontWeight.bold),
          ),
        ),
        new Container(
          padding: new EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 5.0),
          child: new RaisedButton(
            child: new Text("Retry"),
            onPressed: () {
              checkPatrolRegistration(context);
              //getLocalisation(context);
              //getPendingHelpRequestFromServer(true);
            },
          ),
        )
      ],
    );

    var spContent = new Expanded(
      child: buildHelpRequestList(),
    );

    var mainWrapper = new Column(
      children: [
        nameHeader,
        new Container(
          padding: new EdgeInsets.fromLTRB(120.0, 5.0, 5.0, 5.0),
          child: new FlatButton(
            child: new Row(children: [
              new Icon(Icons.refresh),
              new Text(
                "Refresh",
                style: new TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.black54),
              )
            ]),
            onPressed: () {
              setState(() {
                getPendingHelpRequestFromServer();
              });
            },
          ),
        ),
        _pendingHelpRequest ? spContent : waitingRequestGif
      ],
    );

    return new Scaffold(
      drawer: buildDrawer(context),
      appBar: new AppBar(
        title: Common.generateAppTitleBar(),
      ),
      body: new Stack(children: [
        _gpsPositionAvailable
            ? (_dataConnectionAvailable ? mainWrapper : dataErrorRetryWrapper)
            : gpsErrorRetryWrapper,
        _progressHUD
      ]),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  //retrieve localisation
  void getLocalisation(BuildContext context) async {
//show loading dialog
    if ((_progressHUD.state != null)) {
      _progressHUD.state.show();
    }

    var location = new Location();
    try {
      _currentLocation = await location.getLocation();
      Common.myLocation.latitude = _currentLocation["latitude"];
      Common.myLocation.longitude = _currentLocation["longitude"];

      location.onLocationChanged().listen((Map<String, double> currentLocation) {
        Common.myLocation.latitude = currentLocation["latitude"];
        Common.myLocation.longitude = currentLocation["longitude"];
      });
      print('success localisation' + _currentLocation.toString());

      //if ok get list of pending request
      getPendingHelpRequestFromServer(true);

      _gpsPositionAvailable = true;
    } on PlatformException {
      setState(() {
        if ((_progressHUD.state != null)) {
          _progressHUD.state.dismiss();
        }
        _gpsPositionAvailable = false;
      });
      _currentLocation = null;
      showLocalisationSettingsDialog(context);
      print('failed localisation ');
    }
  }

  //get live request details
  void getPendingHelpRequestFromServer([bool firstCall = false]) {
    WebserServiceWrapper.getPendingHelpRequestForProvider(
        Common.providerType,
        Common.myLocation.longitude.toString(),
        Common.myLocation.latitude.toString(),
        Common.patrol.stationId,
        firstCall,
        callbackWsGetExistingHelpReq);
  }

  void callbackWsGetExistingHelpReq(
      List<HelpRequest> helpRequestList, Exception e, bool firstCall) {
    print('callbackWsGetExistingHelpReq');

    if (_progressHUD.state != null) {
      _progressHUD.state.dismiss();
    }

    //cancel timer
    if (refreshListTimer != null) {
      refreshListTimer.cancel();
    }

    if (e == null) {
      setState(() {
        _dataConnectionAvailable = true;
        _gpsPositionAvailable = true;
      });

      var assignmentFound = false;

      if ((helpRequestList != null) && (helpRequestList.length > 0)) {
        //populate list of help
        helpRequestDetails = helpRequestList;
        Common.helpRequestList = helpRequestList;
        print("help request found");
        //check if any request assigned
        if (firstCall) {
          for (var helpRequest in helpRequestDetails) {
            for (var assignment in helpRequest.assignments) {
              if ((assignment.patrolId == Common.patrolID) &&
                  (assignment.status == "TRANSIT")) {
                //go to track info page
                assignmentFound = true;
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => new RequestInfoPage(
                          helpRequest: helpRequest,
                          patrolAssignmentId: assignment.id,
                        ),
                  ),
                );
                break;
              }
            }

            if (assignmentFound) {
              break;
            }
          }
        }

        setState(() {
          _pendingHelpRequest = true;
        });
      } else {
        print("No pending request");
        setState(() {
          _pendingHelpRequest = false;
        });
      }

      refreshListTimer = Timer.periodic(Common.refreshListDuration,
          (Timer t) => getPendingHelpRequestFromServer());
    } else {
      print("error: " + e.toString());
      if (e.toString().startsWith(Common.wsUserError)) {
        showDataConnectionError(
            context, Common.wsUserError, e.toString().split("|").elementAt(1));
      } else {
        showDataConnectionError(
            context, Common.wsTechnicalError + ": " + e.toString());

        setState(() {
          _gpsPositionAvailable = true;
          _dataConnectionAvailable = false;
        });
      }
    }
  }

  ListView buildHelpRequestList() {
    List<Widget> listOfHelpRequest = new List<Widget>();

    for (int i = 0; i < helpRequestDetails.length; i++) {
      print("help request process");
      HelpRequest helpRequest = helpRequestDetails.elementAt(i);

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
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ));

      var spContainer = new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          //Name
          new Container(
            padding: new EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 10.0),
            child: new Row(children: [
              new Container(
                  padding: new EdgeInsets.fromLTRB(70.0, 0.0, 0.0, 0.0),
                  child: new Text(
                    "Name: ",
                    style: new TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold),
                  )),
              new Container(
                  padding: new EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                  child: new Text(
                    helpRequest.name,
                    style: new TextStyle(color: Colors.black, fontSize: 15.0),
                  )),
            ]),
          ),

          //Address
          new Container(
            padding: new EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
            child: new Row(children: [
              new Container(
                padding: new EdgeInsets.fromLTRB(40.0, 0.0, 5.0, 0.0),
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
            ]),
          ),
          //ETA
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
        ],
      );

      var spCard = new Card(
        child: new Container(
          width: 300.0,
          height: 177.0,
          child: new Column(children: [
            spNameHeader,
            new Divider(
              color: Colors.black45,
            ),
            spContainer,
          ]),
        ),
      );

      var spCardDetector = new GestureDetector(
        child: spCard,
        onTap: () {
          Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (context) => new RequestInfoPage(
                    helpRequest: helpRequest,
                    patrolAssignmentId: "",
                  ),
            ),
          );
        },
      );

      listOfHelpRequest.add(new ListTile(
        title: spCardDetector,
      ));
    }

    return ListView(
      addAutomaticKeepAlives: true,
      children: listOfHelpRequest,
    );
  }

  /****** Check Patrol registration * *********/

  checkPatrolRegistration(BuildContext context) {
    //show loading dialog
    if (_progressHUD.state != null) {
      _progressHUD.state.show();
    }

    Common.getDeviceUID().then((uiD) {
      Common.uID = uiD;
      ServiceHelpRequest.retrievePatrolRegistration(uiD).then((response) {
        //dismiss loading dialog
        if ((_progressHUD.state != null)) {
          _progressHUD.state.dismiss();
        }

        if (response.statusCode == 200) {
          Map<String, dynamic> decodedResponse = json.decode(response.body);
          if (decodedResponse["status"] == true) {
            if (decodedResponse["patrol_info"] != null) {
              //registration already done
              Patrol patrol =
                  Patrol.fromJson(decodedResponse["patrol_info"][0]);
              Common.patrol = patrol;
              Common.patrolID = patrol.id;
              Common.providerType = patrol.providerType;

              _registrationNeeded = false;

              //try to get location
              if (_dataConnectionAvailable) {
                getLocalisation(context);
              }
            } else {
              _registrationNeeded = true;

              //route to registration page
              Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (context) => new RegistrationPage(),
                ),
              );
            }
          } else {
            showDataConnectionError(
                context, Common.wsUserError + decodedResponse["error"]);
          }
        }
      }).catchError((e) {
        //dismiss loading dialog
        if ((_progressHUD.state != null)) {
          _progressHUD.state.dismiss();
        }
        showDataConnectionError(
            context, Common.wsTechnicalError + ": " + e.toString());

        setState(() {
          _dataConnectionAvailable = false;
        });
      });
    });
  }

  /****** Handle activity states **********/

  @override
  void dispose() {
    print("dispose called");
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("state has changed: " + state.toString());
    setState(() {
      if (state == AppLifecycleState.resumed) {
        if (_dataConnectionAvailable && _gpsPositionAvailable) {
          refreshListTimer.cancel();
          /*refreshListTimer = Timer.periodic(Common.refreshListDuration,
              (Timer t) => getPendingHelpRequestFromServer());*/
          checkPatrolRegistration(context);
        }
      } else if (state == AppLifecycleState.inactive) {
        if (refreshListTimer != null) {
          refreshListTimer.cancel();
        }
      }
    });
  }
}
