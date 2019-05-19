import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'animations/waiting_text_animation.dart';
import 'services/service_help_request.dart';

class VideoPlayerDialog{

  static Future<Null> showWitnessVideo(BuildContext context, String helpRequestId) async {

  String videoUrl = ServiceHelpRequest.serviceBaseUrl+'welcome/getVideo/'+helpRequestId;
  print(videoUrl);

  return showDialog<Null>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {

    
      var videoWidget = new VideoApp(videoUrl: videoUrl,);

      return new AlertDialog(
        title: new Text('Witness Video'),
        content: 
              new Container(
                height: 600,
                child: videoWidget,
              ),
        //new VideoApp(videoUrl: videoUrl,),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Close'),
              onPressed: () {
                videoWidget.videoController.pause();
                Navigator.pop(context);
                //callback(id);
              }),
        ],
      );
    },
  );
}

}

class VideoApp extends StatefulWidget {
  
  VideoApp({
    Key key,
    this.videoUrl,
  }): super(key: key);

  String videoUrl;
  VideoPlayerController videoController;


  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
   
    widget.videoController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          widget.videoController.setLooping(true);
          widget.videoController.play();
        });
      });

      //animation
    animationController = new AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = new Tween(begin: 0.0, end: 100.0).animate(animationController);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animationController.forward();
      }
    });

    //launch animation
    animationController.forward();
  }


  void _onVideButtonPressed()
  {    
    setState(() {
                    widget.videoController.value.isPlaying
                        ? widget.videoController.pause()
                        : widget.videoController.play();
                  });
  }



  @override
  Widget build(BuildContext context) {
    return widget.videoController.value.initialized ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
              new Container(
                width: 400,
                height: 500,
                child: AspectRatio(
                  aspectRatio: widget.videoController.value.aspectRatio,
                  child: VideoPlayer(widget.videoController),
                ),
              ),
              new IconButton(
              icon: new Icon(widget.videoController.value.isPlaying? Icons.pause : Icons.play_arrow, color: Colors.red,),
              onPressed: _onVideButtonPressed,
            )
        ]) : //waiting gif
      new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        new Container(
          padding: new EdgeInsets.fromLTRB(5.0, 30.0, 5.0, 5.0),
          child: new Image(
            image: new AssetImage("images/double_ring.gif"),
            width: 200.0,
            height: 200.0,
          ),
        ),
        new Container(
          padding: new EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 5.0),
          child: new AnimatedWaitingText(
            animation: animation,
            waitingText: "Video is loading...",
          ),
        ),
      ],
    );
       
  }

  @override
  void dispose() {
    super.dispose();
    widget.videoController.pause();
    widget.videoController.dispose();
  }
}