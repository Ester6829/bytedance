package com.example.bytedance;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import android.content.Context;
import android.content.SharedPreferences;
import android.app.Activity;

import com.bytedance.ads.convert.BDConvert;
import com.bytedance.ads.convert.config.BDConvertConfig;
import com.bytedance.ads.convert.event.ConvertReportHelper;

import org.json.JSONException;
import org.json.JSONObject;


/** BytedancePlugin */
public class BytedancePlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;  
  private Context applicationContext;
  private Activity mainActivity;

  final String USER_STATE_SP = "USER_STATE_SP";
  final String ALREADY_AGREE = "ALREADY_AGREE";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "bytedance");
    channel.setMethodCallHandler(this);
    this.applicationContext = flutterPluginBinding.getApplicationContext();
    initBdConvert();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("uploadRegister")) {
      uploadRegister(call, result);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }


  //初始化
  private void initBdConvert() {
    try {
      BDConvertConfig config = new BDConvertConfig();
      config.setEnableLog(true);
      
      if (mainActivity != null) {
        BDConvert.INSTANCE.init(applicationContext, config, mainActivity);
      }  
    } catch (Exception e) {
      e.printStackTrace();
    }
  }


  private void uploadRegister(MethodCall call, Result result) {
    // 可以传递更多详细信息
    String registerType = call.argument("registerType");
    String userId = call.argument("userId");
    String nickName = call.argument("nickName");

    JSONObject customData = new JSONObject();
    try {
        customData.put("userId", userId);
        customData.put("nickName", nickName); 

         // 详细打印数据
        android.util.Log.d("BytedancePlugin", "Register Type: " + registerType);
        android.util.Log.d("BytedancePlugin", "Custom Data: " + customData.toString());
        android.util.Log.d("BytedancePlugin", "Data contains " + customData.length() + " fields");
  
    } catch (JSONException e) {
        e.printStackTrace();
    }
    ConvertReportHelper.onEventV3("register", customData);
  }
}
