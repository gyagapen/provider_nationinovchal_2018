import 'package:flutter/material.dart';

class Common {
  
  static Container generateAppTitleBar() {
    var appTitleBar = new Container(
        child: new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [
        new ImageIcon(
          AssetImage("images/general_logo.png"),
          size: 100.0,
        ),
        new Text(
          "Provider",
          style: new TextStyle(color: Colors.white),
        )
      ],
    ));

    return appTitleBar;
  }
}
