import 'package:flutter/material.dart';
import 'dart:async';

Future<Null> showConfirmArrivalDialog(BuildContext context, callback) async {
  return showDialog<Null>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return new AlertDialog(
        title: new Text('Log Arrival ?'),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Text('Have you reached the help requestor ?'),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Yes'),
              onPressed: () {
                Navigator.pop(context);
                callback();
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
