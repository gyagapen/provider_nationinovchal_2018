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
                  //start mausafe service
                  Intent i = new Intent();
                  i.setComponent(new ComponentName("gyagapen.testservice", "gyagapen.testservice.TestService"));
                  ComponentName c = getApplicationContext().startService(i);

                  result.success(5);
                }
            }
          });
  }
}
