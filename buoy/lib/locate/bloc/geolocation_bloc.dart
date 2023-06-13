import 'package:bloc/bloc.dart';
import 'package:buoy/activity/bloc/activity_bloc.dart';
import 'package:buoy/locate/model/location.dart';
import 'package:buoy/locate/repository/background_location_repository.dart';
import 'package:buoy/locate/repository/location_realtime_repository.dart';
import 'package:buoy/motion/bloc/motion_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:mapbox_search/mapbox_search.dart' hide Location;
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';

import '../repository/mapbox_search_repository.dart';

part 'geolocation_event.dart';
part 'geolocation_state.dart';

class GeolocationBloc extends Bloc<GeolocationEvent, GeolocationState> {
  final BackgroundLocationRepository _backgroundLocationRepository;
  final LocationRealtimeRepository _locationRealtimeRepository;
  final MapboxSearchRepository _mapboxSearchRepository;
  final ActivityBloc _activityBloc;
  GeolocationBloc(
      {required BackgroundLocationRepository backgroundLocationRepository,
      required LocationRealtimeRepository locationRealtimeRepository,
      required MapboxSearchRepository mapboxSearchRepository,
      required ActivityBloc activityBloc})
      : _backgroundLocationRepository = backgroundLocationRepository,
        _locationRealtimeRepository = locationRealtimeRepository,
        _mapboxSearchRepository = mapboxSearchRepository,
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
      /// Check for location permissions
      PermissionStatus locationWhenInUseStatus =
          await Permission.locationWhenInUse.request();
      PermissionStatus locationAlwaysStatus =
          await Permission.locationAlways.request();
      if (locationWhenInUseStatus.isDenied || locationAlwaysStatus.isDenied) {
        emit(GeolocationDenied(
            message: 'Location permission is required to use this app.'));
        return;
      }
      emit(GeolocationLoading());

      /// Initialize BackgroundGeolocation
      await _backgroundLocationRepository.initBackgroundGeolocation();

      /// Initial location fetch
      bg.Location bgLocation = await _backgroundLocationRepository
          .getCurrentLocation()
          .then((bgLocation) async {
        Location location = Location.fromBGLocation(bgLocation);

        /// Reverse geocode the initial location
        String? address;
        String? city;
        String? state;
        List<MapBoxPlace>? reverseGeocodeResults =
            await _mapboxSearchRepository.reverseGeocode(
                bgLocation.coords.latitude, bgLocation.coords.longitude);
        if (reverseGeocodeResults != null) {
          address = reverseGeocodeResults[0].placeName;

          /// Extract the address components
          city = _mapboxSearchRepository
              .getCityFromMapboxPlace(reverseGeocodeResults[0]);
          state = _mapboxSearchRepository
              .getStateFromMapboxPlace(reverseGeocodeResults[0]);
          location = location.copyWith(
            locationString: address,
            city: city,
            state: state,
          );
          print('Initial address: $address');
        }
        await _locationRealtimeRepository.sendLocationUpdate(location);
        emit(GeolocationLoaded(bgLocation: bgLocation, location: location));

        return bgLocation;
      });

      print('Initial location: $bgLocation');

      _backgroundLocationRepository
          .onLocationChange((bg.Location location) async {
        print('[initial location changed] - $bgLocation');
        add(UpdateGeoLocation(location: location));
      });

      /// Update activity bloc
      _activityBloc.add(LoadActivity(activity: bgLocation.activity.type));
      // _motionBloc.add(LoadMotion(isMoving: location.isMoving));
    } catch (e) {
      emit(GeolocationError(message: e.toString()));
      return;
    }
  }

  void _onUpdateGeoLocation(
    UpdateGeoLocation event,
    Emitter<GeolocationState> emit,
  ) async {
    emit(GeolocationUpdating(bgLocation: event.location));
    try {
      Location location = Location.fromBGLocation(event.location);

      /// Reverse geocode the location
      String? address;
      String? city;
      String? state;

      List<MapBoxPlace>? reverseGeocodeResults =
          await _mapboxSearchRepository.reverseGeocode(
              event.location.coords.latitude, event.location.coords.longitude);
      if (reverseGeocodeResults != null) {
        address = reverseGeocodeResults[0].placeName;
        print('Updated address: $address');

        /// Extract the address components
        city = _mapboxSearchRepository
            .getCityFromMapboxPlace(reverseGeocodeResults[0]);
        state = _mapboxSearchRepository
            .getStateFromMapboxPlace(reverseGeocodeResults[0]);

        location = location.copyWith(
          locationString: address,
          city: city,
          state: state,
        );
      }

      /// Send a location update to the server
      await _locationRealtimeRepository.sendLocationUpdate(location);

      emit(GeolocationLoaded(bgLocation: event.location, location: location));

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
}
