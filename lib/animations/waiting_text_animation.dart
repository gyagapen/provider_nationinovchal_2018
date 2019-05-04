import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import '../helpers/open_settings_menu.dart';

class AnimatedWaitingText extends AnimatedWidget {
  AnimatedWaitingText({Key key, Animation<double> animation, this.waitingText})
      : super(key: key, listenable: animation);

  String waitingText =  "Waiting for new requests";

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;

    var container = new AnimatedOpacity(
      opacity: animation.value > 40 ? 1.0 : 0.0,
      duration: new Duration(milliseconds: 500),
      child: new Container(
        padding: new EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
        //decoration: new BoxDecoration(color: Colors.black45),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            new Container(
              padding: new EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
              child: new Icon(Icons.timer, color: Colors.black),
            ),
            new Container(
              child: new Text(
               waitingText,
                style: new TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );

    return container;
  }
}
