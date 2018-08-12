import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

Future<Null> showQuitApptDialog(BuildContext context) async {
  return showDialog<Null>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return new AlertDialog(
        title: new Text('Cancellation confirmation'),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Text('Do you really want to quit the application ?'),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Yes'),
              onPressed: () {
                exit(0);
              }),
          new FlatButton(
              child: new Text('No'),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      );
    },
  );
}
