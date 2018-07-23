import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'helpers/common.dart';
import 'dialogs/localisation_dialog.dart';
import 'package:progress_hud/progress_hud.dart';
import 'models/help_request.dart';
import 'helpers/webservice_wrapper.dart';
import 'dialogs/dialog_error_webservice.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  var _currentLocation = <String, double>{};
  bool _dataConnectionAvailable = true;
  bool _gpsPositionAvailable = true;
  ProgressHUD _progressHUD;
  List<HelpRequest> helpRequestDetails = new List<HelpRequest>();

  @override
  initState() {
    //try to get location
    getLocalisation(context);

    //initiate progress hud
    _progressHUD = new ProgressHUD(
      backgroundColor: Colors.black54,
      color: Colors.white,
      containerColor: Colors.black,
      borderRadius: 5.0,
      text: 'Loading...',
    );
  }

  @override
  Widget build(BuildContext context) {
    //photo
    var avatarCircle = new Center(
      child: new CircleAvatar(
        backgroundImage: new AssetImage("images/health.png"),
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
            'SAMU - Patrol 1',
            style: new TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
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
              getPendingHelpRequestFromServer();
            },
          ),
        )
      ],
    );

    var mainWrapper = new Column(
      children: [
        nameHeader,
        new Container(
          padding: new EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 5.0),
          child: new RaisedButton(
            child: new Text("Reload help requests"),
            onPressed: () {
              getPendingHelpRequestFromServer();
            },
          ),
        ),
        new Expanded(
          child: buildHelpRequestList(),
        )
      ],
    );

    return new Scaffold(
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
      _currentLocation = await location.getLocation;
      Common.myLocation.latitude = _currentLocation["latitude"];
      Common.myLocation.longitude = _currentLocation["longitude"];

      location.onLocationChanged.listen((Map<String, double> currentLocation) {
        Common.myLocation.latitude = currentLocation["latitude"];
        Common.myLocation.longitude = currentLocation["longitude"];
      });
      print('success localisation' + _currentLocation.toString());

      //if ok get list of pending request
      getPendingHelpRequestFromServer();

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
  void getPendingHelpRequestFromServer() {
    WebserServiceWrapper.getPendingHelpRequestForProvider(
        Common.providerType,
        Common.myLocation.longitude.toString(),
        Common.myLocation.latitude.toString(),
        callbackWsGetExistingHelpReq);
  }

  void callbackWsGetExistingHelpReq(
      List<HelpRequest> helpRequestList, Exception e) {
    if (_progressHUD.state != null) {
      _progressHUD.state.dismiss();
    }

    if (e == null) {
      setState(() {
        _dataConnectionAvailable = true;
        _gpsPositionAvailable = true;
      });

      if (helpRequestList != null) {
        //populate list of help
        helpRequestDetails = helpRequestList;
      } else {
        print("No pending request");
      }
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
      HelpRequest helpRequest = helpRequestDetails.elementAt(i);

      //build help request cards

      var spNameHeader = new Container(
          padding: new EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 25.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              new Container(
                  padding: new EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                  child: new Icon(Icons.help)),
              new Text(
                helpRequest.eventType.toUpperCase(),
                style: new TextStyle(
                  fontSize: 25.0,
                ),
              )
            ],
          ));

      var spContainer = new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          new Container(
            padding: new EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
            child: new Container(
              padding: new EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
              child: new Container(
                child: new Text(
                  helpRequest.name,
                  style: new TextStyle(color: Colors.black, fontSize: 15.0),
                ),
              ),
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              new Container(
                padding: new EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
                child: new Text(
                  helpRequest.latestPosition.distance.eTAmin,
                  style: new TextStyle(
                      fontStyle: FontStyle.italic, fontSize: 15.0),
                ),
              ),
              new Container(
                padding: new EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
                child: new Text(
                  helpRequest.latestPosition.distance.distanceKm,
                  style: new TextStyle(
                      fontStyle: FontStyle.italic, fontSize: 15.0),
                ),
              )
            ],
          )
        ],
      );

      var spCard = new Card(
          child: new Container(
        width: 300.0,
        height: 130.0,
        child: new Column(children: [
          spNameHeader,
          spContainer,
        ]),
      ));

      listOfHelpRequest.add(new ListTile(
        title: spCard,
      ));
    }

    return ListView(
      addAutomaticKeepAlives: true,
      children: listOfHelpRequest,
    );
  }
}
