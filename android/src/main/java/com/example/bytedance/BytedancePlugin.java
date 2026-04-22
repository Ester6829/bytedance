package com.example.bytedance;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import android.content.Context;
import android.app.Activity;
import android.provider.Settings;
import android.util.Log;

import com.bytedance.ads.convert.BDConvert;
import com.bytedance.ads.convert.config.BDConvertConfig;


public class BytedancePlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  private static final String TAG = "BytedancePlugin";
  private MethodChannel channel;
  private Context applicationContext;
  private Activity mainActivity;
  private boolean isInitialized = false;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "bytedance");
    channel.setMethodCallHandler(this);
    this.applicationContext = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.mainActivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    this.mainActivity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    this.mainActivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {
    this.mainActivity = null;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "initSdk":
        initSdk(call, result);
        break;
      case "getId":
        getId(result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private void initSdk(MethodCall call, Result result) {
    try {
      if (isInitialized) { 
        result.success(true);
        return;
      }

      BDConvertConfig config = new BDConvertConfig();
      config.setEnableLog(false);

      if (mainActivity != null) {
        BDConvert.INSTANCE.init(applicationContext, config, mainActivity);
        isInitialized = true; 
        result.success(true);
      } else { 
        result.success(false);
      }
    } catch (Exception e) { 
      result.error("INIT_ERROR", e.getMessage(), null);
    }
  }

  private void getId(Result result) {
    try {
      String androidId = Settings.Secure.getString(
          applicationContext.getContentResolver(),
          Settings.Secure.ANDROID_ID
      );
      result.success(androidId);
    } catch (Exception e) {
      result.success(null);
    }
  }
}
