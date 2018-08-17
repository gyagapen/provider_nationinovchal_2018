import 'package:flutter/material.dart';
import 'helpers/common.dart';
import 'package:progress_hud/progress_hud.dart';
import 'services/service_help_request.dart';
import 'dialogs/dialog_error_webservice.dart';
import 'dart:convert';
import 'dialogs/dialog_quit_app.dart';

class RegistrationPage extends StatefulWidget {
  RegistrationPage({Key key}) : super(key: key);

  @override
  _RegistrationPageState createState() => new _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  ProgressHUD _progressHUD;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<String> _providerTypes = ['SAMU', 'POLICE', 'FIREMAN'];
  String _providerType = 'SAMU';
  String _desc = '';
  String _number = '';

  @override
  initState() {
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
    var title = new Container(
        margin: new EdgeInsets.fromLTRB(75.0, 20.0, 45.0, 5.0),
        child: new Text(
          "One-step registration",
          textAlign: TextAlign.center,
          style: new TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ));

    var subtitle = new Container(
        margin: new EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 5.0),
        child: new Text(
          "Follow these simple steps before using Mausage Provider mobile application",
          textAlign: TextAlign.center,
          style: new TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 15.0,
          ),
        ));

    var form = new Form(
      key: _formKey,
      child: new Column(
        children: [
          //Description
          new Container(
            margin: new EdgeInsets.fromLTRB(20.0, 5.0, 5.0, 15.0),
            child: new TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
              },
              onSaved: (val) => _desc = val,
              keyboardType: TextInputType.text,
              decoration: new InputDecoration(
                hintText: 'Provide a short description',
                hintStyle: new TextStyle(fontStyle: FontStyle.italic),
                labelText: 'Description',
                labelStyle: new TextStyle(fontSize: 20.0),
              ),
            ),
          ),
          //Mobile number
          new Container(
            margin: new EdgeInsets.fromLTRB(20.0, 5.0, 5.0, 15.0),
            child: new TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }

                if (value.length != 8) {
                  return 'Mobile number should contain 8 digits';
                }
              },
              onSaved: (val) => _number = val,
              keyboardType: TextInputType.phone,
              decoration: new InputDecoration(
                hintText: 'Provide a mobile number',
                hintStyle: new TextStyle(fontStyle: FontStyle.italic),
                labelText: 'Mobile number',
                labelStyle: new TextStyle(fontSize: 20.0),
              ),
            ),
          ),
          //Provider type
          new Container(
            margin: new EdgeInsets.fromLTRB(20.0, 5.0, 5.0, 15.0),
            child: new InputDecorator(
              decoration: new InputDecoration(
                labelText: 'Provider Type',
                labelStyle: new TextStyle(fontSize: 20.0),
              ),
              //isEmpTy: _providerType == '',
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                    items: _providerTypes.map((String val) {
                      return new DropdownMenuItem<String>(
                        value: val,
                        child: new Text(val),
                      );
                    }).toList(),
                    value: _providerType,
                    onChanged: (newValue) {
                      setState(() {
                        _providerType = newValue;
                      });
                    }),
              ),
            ),
          ),
          //Token
          new Container(
            margin: new EdgeInsets.fromLTRB(20.0, 5.0, 5.0, 15.0),
            child: new TextFormField(
              enabled: false,
              initialValue: Common.token,
              decoration: new InputDecoration(
                labelText: 'Assigned Token',
                labelStyle: new TextStyle(fontSize: 20.0),
              ),
            ),
          ),
          //UID
          new Container(
            margin: new EdgeInsets.fromLTRB(20.0, 5.0, 5.0, 15.0),
            child: new TextFormField(
              enabled: false,
              initialValue: Common.uID,
              decoration: new InputDecoration(
                labelText: 'Device ID',
                labelStyle: new TextStyle(fontSize: 20.0),
              ),
            ),
          )
        ],
      ),
    );

    var mainWrapper = new ListView(
      children: [
        title,
        subtitle,
        form,
      ],
    );

    var actionButtons = new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        new Container(
          margin: new EdgeInsets.fromLTRB(45.0, 5.0, 10.0, 5.0),
          child: new RaisedButton(
            onPressed: () {
              _submitForm();
            },
            color: Colors.green,
            child: new Row(
              children: [
                new Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                new Text(
                  "Save",
                  style: new TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        new Container(
          margin: new EdgeInsets.fromLTRB(5.0, 5.0, 90.0, 5.0),
          child: new RaisedButton(
            onPressed: () {
              showQuitApptDialog(context);
            },
            color: Colors.red,
            child: new Row(
              children: [
                new Icon(
                  Icons.cancel,
                  color: Colors.white,
                ),
                new Text(
                  "Quit",
                  style: new TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return new WillPopScope(
        onWillPop: () {
          showQuitApptDialog(context);
        },
        child: new Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
            title: Common.generateAppTitleBar(),
          ),
          body: new Stack(children: [mainWrapper, _progressHUD]),
          persistentFooterButtons: [actionButtons],
          // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  void _submitForm() {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Form is not valid!  Please review and correct.');
    } else {
      form.save(); //This invokes each onSaved event

      //show loading progress
      if ((_progressHUD.state != null)) {
        _progressHUD.state.show();
      }

      //submit to server
      ServiceHelpRequest
          .registerPatrol(
              _desc, Common.uID, Common.token, _providerType, _number)
          .then((response) {
        //dismiss loading dialog
        if ((_progressHUD.state != null)) {
          _progressHUD.state.dismiss();
        }

        if (response.statusCode == 200) {
          Map<String, dynamic> decodedResponse = json.decode(response.body);
          if (decodedResponse["status"] == true) {
            if (decodedResponse["id"] != "") {
              //registration correctly submitted
              Common.patrolID = decodedResponse["id"].toString();
              Common.providerType = _providerType;

              Common.registrationJustCompleted = true;
              //pop back
              Navigator.popUntil(context, ModalRoute.withName('/'));
            } else {
              showDataConnectionError(context, Common.wsUserError);
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
      });
    }
  }
}
