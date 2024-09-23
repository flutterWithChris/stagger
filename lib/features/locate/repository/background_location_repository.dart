import 'package:buoy/core/constants.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class BackgroundLocationRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Initialize BackgroundGeolocation
  Future<void> initBackgroundGeolocation() async {
    try {
      final channel = supabase.channel('riders',
          opts: RealtimeChannelConfig(
            key: supabase.auth.currentUser!.id,
          ));

      channel
          .onPresenceSync((payload) {})
          .onPresenceJoin((payload) {})
          .onPresenceLeave((payload) async {
        try {
          await supabase
              .from('location_updates')
              .delete()
              .eq('user_id', Supabase.instance.client.auth.currentUser!.id);

          await bg.BackgroundGeolocation.stop();
        } catch (e) {
          print(e);
        }
      }).subscribe((status, error) async {
        if (status == RealtimeSubscribeStatus.subscribed) {
          await channel.track({'online_at': DateTime.now().toIso8601String()});
        }
        if (status == RealtimeSubscribeStatus.closed) {}
      });
      await bg.BackgroundGeolocation.ready(bg.Config(
              desiredAccuracy: bg.Config.DESIRED_ACCURACY_MEDIUM,
              stopOnTerminate: true,
              debug: false,
              logLevel: bg.Config.LOG_LEVEL_VERBOSE,
              stopTimeout: 3,
              showsBackgroundLocationIndicator: true))
          .then((state) {
        if (!state.enabled) {
          bg.BackgroundGeolocation.start();
        }
      });
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        getErrorSnackbar('Failed to initialize background location.'),
      );
      await Sentry.captureException(
        e,
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Fetch current location
  Future<bg.Location> getCurrentLocation() async {
    try {
      return await bg.BackgroundGeolocation.getCurrentPosition();
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        getErrorSnackbar('Failed to fetch current location.'),
      );
      await Sentry.captureException(
        e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
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

  void onHeartbeat(Function(bg.HeartbeatEvent) callback) {
    bg.BackgroundGeolocation.onHeartbeat(callback);
  }

  /// Subscribe to enabled change events
  void onEnabledChange(Function(bool) callback) {
    bg.BackgroundGeolocation.onEnabledChange(callback);
  }

  // Stop background geolocation
  Future<void> stopBackgroundGeolocation() async {
    try {
      await bg.BackgroundGeolocation.stop();
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        getErrorSnackbar('Failed to stop background location.'),
      );
      await Sentry.captureException(
        e,
        stackTrace: StackTrace.current,
      );
    }
  }
}
