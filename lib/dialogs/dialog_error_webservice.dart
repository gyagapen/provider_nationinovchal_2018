import 'package:flutter/material.dart';
import '../helpers/open_settings_menu.dart';
import '../helpers/common.dart';
import 'dart:async';

Future<Null> showDataConnectionError(context, String errorMsg,
    [String errorDetails = ""]) async {
  List<Widget> flatButtons = new List<Widget>();

  if (errorMsg == Common.wsTechnicalError) {
    flatButtons.add(FlatButton(
        child: new Text('Turn On Wifi/3G'),
        onPressed: () {
          OpenSettings.WirelessMenu();
          Navigator.of(context).pop();
        }));
    flatButtons.add(new FlatButton(
        child: new Text('Cancel'),
        onPressed: () {
          Navigator.of(context).pop();
        }));
  } else {
    flatButtons.add(FlatButton(
        child: new Text('OK'),
        onPressed: () {
          Navigator.of(context).pop();
        }));
  }

  return showDialog<Null>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return new AlertDialog(
        title: new Text('Cannot connect...'),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Text(errorMsg + errorDetails),
            ],
          ),
        ),
        actions: flatButtons,
      );
    },
  );
}
