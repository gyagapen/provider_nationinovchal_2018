import 'package:flutter/material.dart';
import 'dart:async';

Future<Null> showCancelSPRequestDialog(BuildContext context, callback) async {
  return showDialog<Null>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return new AlertDialog(
        title: new Text('Cancellation confirmation'),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Text('Do you really want to cancel this help request ?'),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Yes'),
              onPressed: () {
                //Navigator.popUntil(context, ModalRoute.withName('/'));
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
