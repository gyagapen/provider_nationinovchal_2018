import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'helpers/common.dart';
import 'dialogs/localisation_dialog.dart';

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

  @override
  initState() {
    //try to get location
    getLocalisation(context);
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
        children: [avatarCircle, new Text('SAMU - Patrol 1', style: new TextStyle(fontWeight: FontWeight.bold),)],
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

    var mainWrapper = new Column(
      children: [
        new Text("ok"),
      ],
    );

    return new Scaffold(
      appBar: new AppBar(
        title: Common.generateAppTitleBar(),
      ),
      body: new Stack(children: [
        _gpsPositionAvailable ? mainWrapper : gpsErrorRetryWrapper,
      ]),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  //retrieve localisation
  void getLocalisation(BuildContext context) async {
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
      setState(() {
        _gpsPositionAvailable = true;
      });
    } on PlatformException {
      setState(() {
        _gpsPositionAvailable = false;
      });
      _currentLocation = null;
      showLocalisationSettingsDialog(context);
      print('failed localisation ');
    }
  }
}
