package com.example.mausafeprovider;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import android.content.ComponentName;
import android.content.Intent;
import android.support.v4.content.ContextCompat;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

     new MethodChannel(getFlutterView(), "buildflutter.com/platform").setMethodCallHandler(
          new MethodCallHandler()
          {
            @Override
            public void onMethodCall(MethodCall call, Result result) {
                if (call.method.equals("startMausafeService"))
                {

                  //retrieve parameters
                  String patrolId = call.argument("patrolId");
                  String helprequestId = call.argument("helprequestId");
                  String intervalLocation = call.argument("intervalLocation");
                  String urlEndPoint = call.argument("urlEndPoint");
                  String xApiKey = call.argument("xApiKey");

                  //start mausafe service
                  Intent i = new Intent();
                  i.setComponent(new ComponentName("gyagapen.testservice", "gyagapen.testservice.MausafeService"));

                  i.putExtra("patrolId", patrolId);
                  i.putExtra("helprequestId",helprequestId);
                  i.putExtra("intervalLocation", intervalLocation);
                  i.putExtra("urlEndPoint", urlEndPoint);
                  i.putExtra("xApiKey",xApiKey);

                  ContextCompat.startForegroundService(getApplicationContext(), i);

                  result.success(5);
                }else if (call.method.equals("stopMausafeService"))
                {
                  //stop mausafe service
                  Intent i = new Intent();
                  i.setComponent(new ComponentName("gyagapen.testservice", "gyagapen.testservice.MausafeService"));
                  getApplicationContext().stopService(i);
                }
            }
          });
  }
}
