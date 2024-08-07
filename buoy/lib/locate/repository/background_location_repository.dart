import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

class BackgroundLocationRepository {
  /// Initialize BackgroundGeolocation
  Future<void> initBackgroundGeolocation() async {
    await bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_MEDIUM,
      stopOnTerminate: true,
      debug: false,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE,
    )).then((state) {
      if (!state.enabled) {
        bg.BackgroundGeolocation.start();
      }
    });
  }

  /// Fetch current location
  Future<bg.Location> getCurrentLocation() async {
    return await bg.BackgroundGeolocation.getCurrentPosition();
  }

  /// Subscribe to motion change events
  void onMotionChange(Function(bg.Location) callback) {
    bg.BackgroundGeolocation.onMotionChange(callback);
  }

  /// Subscribe to location change events
  void onLocationChange(Function(bg.Location) callback) {
    bg.BackgroundGeolocation.onLocation(callback);
  }

  /// Subscribe to activity change events
  void onActivityChange(Function(bg.ActivityChangeEvent) callback) {
    bg.BackgroundGeolocation.onActivityChange(callback);
  }

  /// Subscribe to geofence events
  void onGeofence(Function(bg.GeofenceEvent) callback) {
    bg.BackgroundGeolocation.onGeofence(callback);
  }

  /// Susbcribe tp connectivity change events
  void onConnectivityChange(Function(bg.ConnectivityChangeEvent) callback) {
    bg.BackgroundGeolocation.onConnectivityChange(callback);
  }

  /// Subscribe to power save change events
  void onPowerSaveChange(Function(bool) callback) {
    bg.BackgroundGeolocation.onPowerSaveChange(callback);
  }

  /// Subscribe to enabled change events
  void onEnabledChange(Function(bool) callback) {
    bg.BackgroundGeolocation.onEnabledChange(callback);
  }
}
