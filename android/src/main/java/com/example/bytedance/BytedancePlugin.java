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
import com.bytedance.ads.convert.event.ConvertReportHelper;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;


public class BytedancePlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  private static final String TAG = "BytedancePlugin";
  private MethodChannel channel;
  private Context applicationContext;
  private Activity mainActivity;
  private boolean isInitialized = false;
  private String currentUserId = null;

  final String USER_STATE_SP = "USER_STATE_SP";
  final String ALREADY_AGREE = "ALREADY_AGREE";

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
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "initSdk":
        initSdk(call, result);
        break;
      case "uploadRegister":
        uploadRegister(call, result);
        break;
      case "uploadLogin":
        uploadLogin(call, result);
        break;
      case "uploadPurchase":
        uploadPurchase(call, result);
        break;
      case "uploadCustomEvent":
        uploadCustomEvent(call, result);
        break;
      case "trackEvent":
        trackEvent(call, result);
        break;
      case "setUserId":
        setUserId(call, result);
        break;
      case "clearUserId":
        clearUserId(result);
        break;
      case "getIdfv":
        result.success(null);
        break;
      case "getIdfa":
        result.success(null);
        break;
      case "getAndroidId":
        getAndroidId(result);
        break;
      case "setDebugMode":
        setDebugMode(call, result);
        break;
      case "getAttributionData":
        getAttributionData(result);
        break;
      case "requestAttribution":
        requestAttribution(result);
        break;
      case "getCachedAttributionData":
        getCachedAttributionData(result);
        break;
      case "getPendingDeepLink":
        getPendingDeepLink(result);
        break;
      case "clearPendingDeepLink":
        clearPendingDeepLink(result);
        break;
      case "trackAppActivate":
        trackAppActivate(call, result);
        break;
      case "trackAppDeactivate":
        trackAppDeactivate(result);
        break;
      case "trackPageView":
        trackPageView(call, result);
        break;
      case "uploadActiveRegister":
        uploadActiveRegister(call, result);
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
      // 如果已经初始化，直接返回成功
      if (isInitialized) {
        Log.d(TAG, "SDK already initialized");
        result.success(true);
        return;
      }

      Boolean isDebug = call.argument("isDebug");
      String userId = call.argument("userId");
      String appId = call.argument("appId");
      String appName = call.argument("appName");
      String channel = call.argument("channel");
      Boolean enableOaid = call.argument("enableOaid");

      BDConvertConfig config = new BDConvertConfig();
      config.setEnableLog(isDebug != null ? isDebug : false);

      if (mainActivity != null) {
        BDConvert.INSTANCE.init(applicationContext, config, mainActivity);
        isInitialized = true;

        if (userId != null && !userId.isEmpty()) {
          currentUserId = userId;
        }

        Log.d(TAG, "SDK initialized successfully");
        result.success(true);
      } else {
        Log.e(TAG, "Main activity is null, cannot initialize SDK");
        result.success(false);
      }
    } catch (Exception e) {
      Log.e(TAG, "SDK init error", e);
      result.error("INIT_ERROR", e.getMessage(), null);
    }
  }

  private void setDebugMode(MethodCall call, Result result) {
    try {
      Boolean enable = call.argument("enable");
      if (enable != null) {
        BDConvertConfig config = new BDConvertConfig();
        config.setEnableLog(enable);
      }
      result.success(true);
    } catch (Exception e) {
      result.error("DEBUG_MODE_ERROR", e.getMessage(), null);
    }
  }

  private void setUserId(MethodCall call, Result result) {
    if (!isInitialized) {
      result.error("SDK_NOT_INITIALIZED", "SDK not initialized. Please call initSdk first.", null);
      return;
    }
    try {
      String userId = call.argument("userId");
      if (userId != null) {
        currentUserId = userId;
      }
      result.success(true);
    } catch (Exception e) {
      result.error("SET_USER_ID_ERROR", e.getMessage(), null);
    }
  }

  private void clearUserId(Result result) {
    if (!isInitialized) {
      result.error("SDK_NOT_INITIALIZED", "SDK not initialized. Please call initSdk first.", null);
      return;
    }
    try {
      currentUserId = null;
      result.success(true);
    } catch (Exception e) {
      result.error("CLEAR_USER_ID_ERROR", e.getMessage(), null);
    }
  }

  private void uploadRegister(MethodCall call, Result result) {
    if (!isInitialized) {
      result.error("SDK_NOT_INITIALIZED", "SDK not initialized. Please call initSdk first.", null);
      return;
    }
    try {
      String userId = call.argument("userId");
      String nickName = call.argument("nickName");
      String registerType = call.argument("registerType");

      JSONObject customData = new JSONObject();
      if (userId != null) customData.put("userId", userId);
      if (nickName != null) customData.put("nickName", nickName);
      if (registerType != null) customData.put("registerType", registerType);

      ConvertReportHelper.onEventV3("register", customData);
      result.success(true);
    } catch (JSONException e) {
      result.error("JSON_ERROR", e.getMessage(), null);
    } catch (Exception e) {
      result.error("UPLOAD_ERROR", e.getMessage(), null);
    }
  }

  private void uploadLogin(MethodCall call, Result result) {
    if (!isInitialized) {
      result.error("SDK_NOT_INITIALIZED", "SDK not initialized. Please call initSdk first.", null);
      return;
    }
    try {
      String userId = call.argument("userId");
      String method = call.argument("method");

      JSONObject customData = new JSONObject();
      if (userId != null) customData.put("userId", userId);
      if (method != null) customData.put("method", method);

      ConvertReportHelper.onEventV3("login", customData);
      result.success(true);
    } catch (JSONException e) {
      result.error("JSON_ERROR", e.getMessage(), null);
    } catch (Exception e) {
      result.error("UPLOAD_ERROR", e.getMessage(), null);
    }
  }

  private void uploadPurchase(MethodCall call, Result result) {
    if (!isInitialized) {
      result.error("SDK_NOT_INITIALIZED", "SDK not initialized. Please call initSdk first.", null);
      return;
    }
    try {
      String orderId = call.argument("orderId");
      Double amount = call.argument("amount");
      String currency = call.argument("currency");
      String productId = call.argument("productId");
      String productName = call.argument("productName");
      Integer quantity = call.argument("quantity");

      JSONObject customData = new JSONObject();
      if (orderId != null) customData.put("orderId", orderId);
      if (amount != null) customData.put("amount", amount);
      if (currency != null) customData.put("currency", currency);
      if (productId != null) customData.put("productId", productId);
      if (productName != null) customData.put("productName", productName);
      if (quantity != null) customData.put("quantity", quantity);

      ConvertReportHelper.onEventV3("purchase", customData);
      result.success(true);
    } catch (JSONException e) {
      result.error("JSON_ERROR", e.getMessage(), null);
    } catch (Exception e) {
      result.error("UPLOAD_ERROR", e.getMessage(), null);
    }
  }

  private void uploadCustomEvent(MethodCall call, Result result) {
    if (!isInitialized) {
      result.error("SDK_NOT_INITIALIZED", "SDK not initialized. Please call initSdk first.", null);
      return;
    }
    try {
      String eventName = call.argument("eventName");
      Map<String, Object> params = call.argument("params");

      JSONObject customData = new JSONObject();
      if (params != null) {
        for (Map.Entry<String, Object> entry : params.entrySet()) {
          customData.put(entry.getKey(), entry.getValue());
        }
      }

      ConvertReportHelper.onEventV3(eventName, customData);
      result.success(true);
    } catch (JSONException e) {
      result.error("JSON_ERROR", e.getMessage(), null);
    } catch (Exception e) {
      result.error("UPLOAD_ERROR", e.getMessage(), null);
    }
  }

  private void trackEvent(MethodCall call, Result result) {
    uploadCustomEvent(call, result);
  }

  private void getAndroidId(Result result) {
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

  private void getAttributionData(Result result) {
    try {
      Map<String, Object> data = new HashMap<>();
      data.put("androidId", getAndroidIdSync());
      data.put("platform", "Android");
      data.put("osVersion", android.os.Build.VERSION.RELEASE);
      if (currentUserId != null) {
        data.put("userId", currentUserId);
      }

      result.success(data);
    } catch (Exception e) {
      Map<String, Object> errorData = new HashMap<>();
      errorData.put("error", e.getMessage());
      errorData.put("androidId", getAndroidIdSync());
      errorData.put("platform", "Android");
      errorData.put("osVersion", android.os.Build.VERSION.RELEASE);
      result.success(errorData);
    }
  }

  private String getAndroidIdSync() {
    try {
      return Settings.Secure.getString(
          applicationContext.getContentResolver(),
          Settings.Secure.ANDROID_ID
      );
    } catch (Exception e) {
      return null;
    }
  }

  private void trackAppActivate(MethodCall call, Result result) {
    if (!isInitialized) {
      result.error("SDK_NOT_INITIALIZED", "SDK not initialized. Please call initSdk first.", null);
      return;
    }
    try {
      JSONObject customData = new JSONObject();
      String userId = call.argument("userId");
      if (userId != null) customData.put("userId", userId);

      ConvertReportHelper.onEventV3("app_activate", customData);
      result.success(true);
    } catch (JSONException e) {
      result.error("JSON_ERROR", e.getMessage(), null);
    } catch (Exception e) {
      Log.e(TAG, "Track app activate error", e);
      result.error("TRACK_ERROR", e.getMessage(), null);
    }
  }

  private void trackAppDeactivate(Result result) {
    if (!isInitialized) {
      result.error("SDK_NOT_INITIALIZED", "SDK not initialized. Please call initSdk first.", null);
      return;
    }
    try {
      JSONObject customData = new JSONObject();
      ConvertReportHelper.onEventV3("app_deactivate", customData);
      result.success(true);
    } catch (Exception e) {
      Log.e(TAG, "Track app deactivate error", e);
      result.error("TRACK_ERROR", e.getMessage(), null);
    }
  }

  private void trackPageView(MethodCall call, Result result) {
    if (!isInitialized) {
      result.error("SDK_NOT_INITIALIZED", "SDK not initialized. Please call initSdk first.", null);
      return;
    }
    try {
      String pageName = call.argument("pageName");
      String pageUrl = call.argument("pageUrl");
      String referrer = call.argument("referrer");
      Map<String, Object> extraParams = call.argument("extraParams");

      JSONObject customData = new JSONObject();
      if (pageName != null) customData.put("pageName", pageName);
      if (pageUrl != null) customData.put("pageUrl", pageUrl);
      if (referrer != null) customData.put("referrer", referrer);

      if (extraParams != null) {
        for (Map.Entry<String, Object> entry : extraParams.entrySet()) {
          customData.put(entry.getKey(), entry.getValue());
        }
      }

      ConvertReportHelper.onEventV3("page_view", customData);
      result.success(true);
    } catch (JSONException e) {
      result.error("JSON_ERROR", e.getMessage(), null);
    } catch (Exception e) {
      Log.e(TAG, "Track page view error", e);
      result.error("TRACK_ERROR", e.getMessage(), null);
    }
  }

  private void uploadActiveRegister(MethodCall call, Result result) {
    if (!isInitialized) {
      result.error("SDK_NOT_INITIALIZED", "SDK not initialized. Please call initSdk first.", null);
      return;
    }
    try {
      String userId = call.argument("userId");
      String registerType = call.argument("registerType");
      String channel = call.argument("channel");
      Map<String, Object> extraParams = call.argument("extraParams");

      JSONObject customData = new JSONObject();
      if (userId != null) customData.put("userId", userId);
      if (registerType != null) customData.put("registerType", registerType);
      if (channel != null) customData.put("channel", channel);

      if (extraParams != null) {
        for (Map.Entry<String, Object> entry : extraParams.entrySet()) {
          customData.put(entry.getKey(), entry.getValue());
        }
      }

      ConvertReportHelper.onEventV3("active_register", customData);
      result.success(true);
    } catch (JSONException e) {
      result.error("JSON_ERROR", e.getMessage(), null);
    } catch (Exception e) {
      Log.e(TAG, "Upload active register error", e);
      result.error("UPLOAD_ERROR", e.getMessage(), null);
    }
  }

  private void requestAttribution(Result result) {
    try {
      result.success(true);
    } catch (Exception e) {
      Log.e(TAG, "Request attribution error", e);
      result.error("REQUEST_ATTRIBUTION_ERROR", e.getMessage(), null);
    }
  }

  private void getCachedAttributionData(Result result) {
    try {
      Map<String, Object> data = new HashMap<>();
      data.put("androidId", getAndroidIdSync());
      data.put("platform", "Android");
      data.put("osVersion", android.os.Build.VERSION.RELEASE);
      if (currentUserId != null) {
        data.put("userId", currentUserId);
      }
      result.success(data);
    } catch (Exception e) {
      Log.e(TAG, "Get cached attribution data error", e);
      Map<String, Object> errorData = new HashMap<>();
      errorData.put("error", e.getMessage());
      errorData.put("androidId", getAndroidIdSync());
      errorData.put("platform", "Android");
      errorData.put("osVersion", android.os.Build.VERSION.RELEASE);
      result.success(errorData);
    }
  }

  private void getPendingDeepLink(Result result) {
    try {
      result.success(null);
    } catch (Exception e) {
      Log.e(TAG, "Get pending deep link error", e);
      result.error("GET_DEEP_LINK_ERROR", e.getMessage(), null);
    }
  }

  private void clearPendingDeepLink(Result result) {
    try {
      result.success(true);
    } catch (Exception e) {
      Log.e(TAG, "Clear pending deep link error", e);
      result.error("CLEAR_DEEP_LINK_ERROR", e.getMessage(), null);
    }
  }
}
