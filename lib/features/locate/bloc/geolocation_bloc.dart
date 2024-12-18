import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bloc/bloc.dart';
import 'package:buoy/features/activity/bloc/activity_bloc.dart';
import 'package:buoy/features/locate/model/location.dart';
import 'package:buoy/features/locate/repository/background_location_repository.dart';
import 'package:buoy/features/locate/repository/encryption_repository.dart';
import 'package:buoy/features/locate/repository/location_realtime_repository.dart';
import 'package:buoy/features/locate/repository/public_key_repository.dart';
import 'package:buoy/core/constants.dart';
import 'package:buoy/features/notifications/domain/usecase/show_notification_usecase.dart';
import 'package:compassx/compassx.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mapbox_search/mapbox_search.dart' hide Location;
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../repository/mapbox_search_repository.dart';

part 'geolocation_event.dart';
part 'geolocation_state.dart';

class GeolocationBloc extends Bloc<GeolocationEvent, GeolocationState> {
  final BackgroundLocationRepository _backgroundLocationRepository;
  final LocationRealtimeRepository _locationRealtimeRepository;
  final MapboxSearchRepository _mapboxSearchRepository;
  final PublicKeyRepository _publicKeyRepository;
  final ActivityBloc _activityBloc;
  final List<bg.Location> _locationUpdates = [];
  final EncryptionRepository _encryptionRepository;
  final ShowNotificationUsecase showNotificationUsecase;
  bool locationUpdatesEnabled = false;
  StreamSubscription? _compassSubscription;
  Timer? _timer;
  Timer? _locationDelayTimer;
  bool _locationTrackingNotificationShown = false;

  GeolocationBloc({
    required BackgroundLocationRepository backgroundLocationRepository,
    required LocationRealtimeRepository locationRealtimeRepository,
    required MapboxSearchRepository mapboxSearchRepository,
    required PublicKeyRepository publicKeyRepository,
    required ActivityBloc activityBloc,
    required EncryptionRepository encryptionRepository,
    required this.showNotificationUsecase,
  })  : _backgroundLocationRepository = backgroundLocationRepository,
        _locationRealtimeRepository = locationRealtimeRepository,
        _mapboxSearchRepository = mapboxSearchRepository,
        _encryptionRepository = encryptionRepository,
        _publicKeyRepository = publicKeyRepository,
        _activityBloc = activityBloc,
        super(GeolocationLoading()) {
    on<LoadGeolocation>(
      _onLoadGeolocation,
    );
    on<UpdateGeoLocation>(_onUpdateGeoLocation,
        transformer: throttle(const Duration(minutes: 2)));
    on<StopGeoLocation>(_onStopGeoLocation);
  }

  void _onLoadGeolocation(
    LoadGeolocation event,
    Emitter<GeolocationState> emit,
  ) async {
    try {
      emit(GeolocationLoading());

      /// Check for location permissions
      PermissionStatus locationWhenInUseStatus =
          await Permission.locationWhenInUse.request();
      PermissionStatus locationAlwaysStatus =
          await Permission.locationAlways.request();
      if (locationWhenInUseStatus.isDenied || locationAlwaysStatus.isDenied) {
        emit(const GeolocationDenied(
            message: 'Location permission is required to use this app.'));
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      locationUpdatesEnabled = prefs.getBool('locationUpdatesEnabled') ?? false;

      /// Initialize BackgroundGeolocation
      await _backgroundLocationRepository.initBackgroundGeolocation();
      Location? updatedLocation;

      /// Initial location fetch
      bg.Location bgLocation = await _backgroundLocationRepository
          .getCurrentLocation()
          .then((bgLocation) async {
        if (locationUpdatesEnabled == false) {
          return bgLocation;
        } else {
          updatedLocation = await _sendLocationUpdateToDB(bgLocation);
          if (updatedLocation == null) {
            emit(const GeolocationError(message: 'Failed to fetch location.'));
            return bgLocation;
          }
          return bgLocation;
        }
      });
      if (_locationTrackingNotificationShown == false) {
        await showNotificationUsecase.call('Stagger', 'Location Service Active',
            category: NotificationCategory.Service);

        _locationTrackingNotificationShown = true;
      }
      if (bgLocation.isMoving == true) {
        _stillnessTimer?.cancel();
        _stillnessTimer = Timer(const Duration(minutes: 30), () async {
          await _locationRealtimeRepository.deleteLocationUpdate(
              Supabase.instance.client.auth.currentUser!.id);
          await _backgroundLocationRepository.stopBackgroundGeolocation();
          emit(GeolocationStopped());
        });
      }

      if (updatedLocation == null) {
        emit(GeolocationLoaded(bgLocation: bgLocation));
        return;
      }
      emit(
          GeolocationLoaded(bgLocation: bgLocation, location: updatedLocation));

      _backgroundLocationRepository
          .onLocationChange((bg.Location updatedLocation) async {
        add(UpdateGeoLocation(location: updatedLocation));
        return;
      });
    } catch (e) {
      emit(GeolocationError(message: e.toString()));
      return;
    }
  }

  Future<Location?> _sendLocationUpdateToDB(bg.Location bgLocation) async {
    try {
      Location location = Location.fromBGLocation(bgLocation).copyWith(
        activity: null,
        isMoving: null,
        batteryLevel: null,
        includeNull: true,
      );

      /// Reverse geocode the initial location
      String? address;
      String? city;
      String? state;
      ({
        FailureResponse? failure,
        List<MapBoxPlace>? success
      })? reverseGeocodeResults = await _mapboxSearchRepository.reverseGeocode(
          bgLocation.coords.latitude, bgLocation.coords.longitude);
      if (reverseGeocodeResults?.failure != null) {
        throw Exception(reverseGeocodeResults!.failure!.message!);
      }
      if (reverseGeocodeResults?.success != null) {
        address = reverseGeocodeResults!.success![0].placeName;

        /// Extract the address components
        city = _mapboxSearchRepository
            .getCityFromMapboxPlace(reverseGeocodeResults.success![0]);
        state = _mapboxSearchRepository
            .getStateFromMapboxPlace(reverseGeocodeResults.success![0]);
        location = location.copyWith(
          locationString: address,
          city: city,
          state: state,
        );
      }

      await _locationRealtimeRepository.sendLocationUpdate(location);

      return location;
    } catch (e) {
      return null;
    }
  }

  Timer? _stillnessTimer;

  void _onUpdateGeoLocation(
    UpdateGeoLocation event,
    Emitter<GeolocationState> emit,
  ) async {
    emit(GeolocationUpdating(bgLocation: event.location));
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool activityTrackingEnabled =
          prefs.getBool('activityTrackingEnabled') ?? false;
      bool motionTrackingEnabled =
          prefs.getBool('motionTrackingEnabled') ?? false;
      bool batteryTrackingEnabled =
          prefs.getBool('batteryTrackingEnabled') ?? false;

      Location location = Location.fromBGLocation(event.location).copyWith(
          activity:
              activityTrackingEnabled ? event.location.activity.type : null,
          isMoving: motionTrackingEnabled ? event.location.isMoving : null,
          batteryLevel: batteryTrackingEnabled
              ? (event.location.battery.level * 100).toInt()
              : null,
          includeNull: true);

      /// Reverse geocode the location
      String? address;
      String? city;
      String? state;

      ({
        FailureResponse? failure,
        List<MapBoxPlace>? success
      })? reverseGeocodeResults = await _mapboxSearchRepository.reverseGeocode(
          event.location.coords.latitude, event.location.coords.longitude);
      if (reverseGeocodeResults?.success != null) {
        address = reverseGeocodeResults!.success![0].placeName;

        /// Extract the address components
        city = _mapboxSearchRepository
            .getCityFromMapboxPlace(reverseGeocodeResults.success![0]);
        state = _mapboxSearchRepository
            .getStateFromMapboxPlace(reverseGeocodeResults.success![0]);

        location = location.copyWith(
          locationString: address,
          city: city,
          state: state,
        );
      }

      _locationDelayTimer?.cancel();

      /// Encrypt Location & Send a location update to the server
      if (locationUpdatesEnabled == true) {
        _locationDelayTimer = Timer(const Duration(minutes: 2), () async {
          await _locationRealtimeRepository.sendLocationUpdate(location);
        });
      }

      // Handle stillness: Cancel previous stillness timer if user is moving
      if (event.location.isMoving == true) {
        _stillnessTimer?.cancel();
        // Restart 30-minute inactivity timer if user stops moving
        _stillnessTimer = Timer(const Duration(minutes: 30), () async {
          await _locationRealtimeRepository.deleteLocationUpdate(
              Supabase.instance.client.auth.currentUser!.id);
          await _backgroundLocationRepository.stopBackgroundGeolocation();
          emit(GeolocationStopped());
        });
      }
      emit(GeolocationLoaded(bgLocation: event.location, location: location));

      // await emit.forEach(CompassX.events ?? const Stream.empty(),
      //     onData: (compassEvent) {
      //   location = location.copyWith(heading: compassEvent.heading);
      //   return GeolocationLoaded(
      //       bgLocation: event.location, location: location);
      // });

      /// Listen for location changes
      _backgroundLocationRepository
          .onLocationChange((bg.Location location) async {
        add(UpdateGeoLocation(location: location));
      });
    } catch (e) {
      emit(GeolocationError(message: e.toString()));
      return;
    }
  }

  void _onStopGeoLocation(
    StopGeoLocation event,
    Emitter<GeolocationState> emit,
  ) async {
    try {
      var oldState = state;
      emit(GeolocationLoading());
      await _locationRealtimeRepository
          .deleteLocationUpdate(Supabase.instance.client.auth.currentUser!.id);
      locationUpdatesEnabled = false;
      // await _backgroundLocationRepository.stopBackgroundGeolocation();
      emit(GeolocationLoaded(
          bgLocation: oldState.bgLocation!,
          location: oldState.location!,
          locationUpdatesEnabled: false));
    } catch (e) {
      emit(GeolocationError(message: e.toString()));
      return;
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _locationDelayTimer?.cancel();
    return super.close();
  }
}
