import 'package:flutter/material.dart';
import '../helpers/common.dart';
import 'dart:async';

Future<Null> showAssignmentErrorDialog(
    BuildContext context, String errorMsg) async {
  return showDialog<Null>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return new AlertDialog(
        title: new Text('Assignment exception'),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Text(errorMsg),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Ok'),
              onPressed: () {
                //Navigator.pop(context);
                Common.stopMausafeService();
                Navigator.popUntil(context, ModalRoute.withName('/'));
              }),
        ],
      );
    },
  );
}
