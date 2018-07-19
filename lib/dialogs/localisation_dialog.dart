import 'package:flutter/material.dart';
import '../helpers/open_settings_menu.dart';
import 'dart:async';

Future<Null> showLocalisationSettingsDialog(context) async {
  return showDialog<Null>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return new AlertDialog(
        title: new Text('Please turn on localisation '),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Text('Please turn on localisation so that we can assist you.'),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Turn On GPS'),
              onPressed: () {
                OpenSettings.GPSMenu();
                Navigator.of(context).pop();
              }),
          new FlatButton(
              child: new Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ],
      );
    },
  );
}
