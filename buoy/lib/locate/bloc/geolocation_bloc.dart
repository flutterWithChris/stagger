import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:buoy/activity/bloc/activity_bloc.dart';
import 'package:buoy/locate/model/location.dart';
import 'package:buoy/locate/repository/background_location_repository.dart';
import 'package:buoy/locate/repository/encryption_repository.dart';
import 'package:buoy/locate/repository/location_realtime_repository.dart';
import 'package:buoy/locate/repository/public_key_repository.dart';
import 'package:buoy/shared/constants.dart';
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
  StreamSubscription? _compassSubscription;
  Timer? _timer;
  Timer? _locationDelayTimer;

  GeolocationBloc(
      {required BackgroundLocationRepository backgroundLocationRepository,
      required LocationRealtimeRepository locationRealtimeRepository,
      required MapboxSearchRepository mapboxSearchRepository,
      required PublicKeyRepository publicKeyRepository,
      required ActivityBloc activityBloc,
      required EncryptionRepository encryptionRepository})
      : _backgroundLocationRepository = backgroundLocationRepository,
        _locationRealtimeRepository = locationRealtimeRepository,
        _mapboxSearchRepository = mapboxSearchRepository,
        _encryptionRepository = encryptionRepository,
        _publicKeyRepository = publicKeyRepository,
        _activityBloc = activityBloc,
        super(GeolocationInitial()) {
    on<LoadGeolocation>(_onLoadGeolocation);
    on<UpdateGeoLocation>(_onUpdateGeoLocation);
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

      /// Initialize BackgroundGeolocation
      await _backgroundLocationRepository.initBackgroundGeolocation();

      _backgroundLocationRepository
          .onLocationChange((bg.Location updatedLocation) async {
        print('Location Updated: $updatedLocation');
        add(UpdateGeoLocation(location: updatedLocation));
        return;
        if (state is GeolocationUpdating) {
          return;
        }
        emit(GeolocationUpdating(bgLocation: updatedLocation));

        print('[Location Updated] - $updatedLocation');
        if (updatedLocation.coords.heading != -1.0) {
          scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
            content: Text(
              'Location updated! Heading: ${updatedLocation.coords.heading},',
            ),
            backgroundColor: Colors.green,
          ));
        }
        Location? location = await _handleLocationChange(updatedLocation);
        if (location == null) {
          scaffoldMessengerKey.currentState!.showSnackBar(const SnackBar(
            content: Text(
              'Failed to fetch location!',
            ),
            backgroundColor: Colors.red,
          ));
          emit(const GeolocationError(message: 'Failed to fetch location.'));
          return;
        }
        emit(
            GeolocationLoaded(bgLocation: updatedLocation, location: location));
      });

      /// Initial location fetch
      bg.Location bgLocation = await _backgroundLocationRepository
          .getCurrentLocation()
          .then((bgLocation) async {
        Location? updatedLocation = await _handleLocationChange(bgLocation);
        if (updatedLocation == null) {
          emit(const GeolocationError(message: 'Failed to fetch location.'));
          return bgLocation;
        }
        print('Initial Location: $updatedLocation');
        emit(GeolocationLoaded(
            bgLocation: bgLocation, location: updatedLocation));

        return bgLocation;
      });

      /// Update activity bloc
      // _activityBloc.add(LoadActivity(activity: bgLocation.activity.type));
      // _motionBloc.add(LoadMotion(isMoving: location.isMoving));
      // emit(GeolocationLoaded(bgLocation: bgLocation));
    } catch (e) {
      emit(GeolocationError(message: e.toString()));
      return;
    }
  }

  Future<Location?> _handleLocationChange(bg.Location bgLocation) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool activityTrackingEnabled =
          prefs.getBool('activityTrackingEnabled') ?? false;
      bool motionTrackingEnabled =
          prefs.getBool('motionTrackingEnabled') ?? false;
      bool batteryTrackingEnabled =
          prefs.getBool('batteryTrackingEnabled') ?? false;

      print('activityTrackingEnabled: $activityTrackingEnabled');
      print('motionTrackingEnabled: $motionTrackingEnabled');
      print('batteryTrackingEnabled: $batteryTrackingEnabled');

      Location location = Location.fromBGLocation(bgLocation).copyWith(
        activity: activityTrackingEnabled ? bgLocation.activity.type : null,
        isMoving: motionTrackingEnabled ? bgLocation.isMoving : null,
        batteryLevel: batteryTrackingEnabled
            ? (bgLocation.battery.level * 100).toInt()
            : null,
        includeNull: true,
      );
      print('Handling Location: ${location.toJson().toString()}');

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
        print('Initial address: $address');
      }

      // _locationDelayTimer = Timer(const Duration(minutes: 2), () async {
      //   await _locationRealtimeRepository.sendLocationUpdate(location);
      // });

      return location;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

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

      print('activityTrackingEnabled: $activityTrackingEnabled');

      Location location = Location.fromBGLocation(event.location).copyWith(
          activity:
              activityTrackingEnabled ? event.location.activity.type : null,
          isMoving: motionTrackingEnabled ? event.location.isMoving : null,
          batteryLevel: batteryTrackingEnabled
              ? (event.location.battery.level * 100).toInt()
              : null,
          includeNull: true);

      print('Updated location: $location');

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
        print('Updated address: $address');

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

      /// Encrypt Location & Send a location update to the server

      _locationDelayTimer = Timer(const Duration(minutes: 2), () async {
        await _locationRealtimeRepository.sendLocationUpdate(location);
      });
      emit(GeolocationLoaded(bgLocation: event.location, location: location));

      // await emit.forEach(CompassX.events ?? const Stream.empty(),
      //     onData: (compassEvent) {
      //   print('Compass Event: ${compassEvent.heading}');
      //   location = location.copyWith(heading: compassEvent.heading);
      //   return GeolocationLoaded(
      //       bgLocation: event.location, location: location);
      // });

      /// Listen for location changes
      _backgroundLocationRepository
          .onLocationChange((bg.Location location) async {
        print('[location updated] - $location');
        add(UpdateGeoLocation(location: location));
      });
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
