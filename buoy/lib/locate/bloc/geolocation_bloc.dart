import 'package:bloc/bloc.dart';
import 'package:buoy/activity/bloc/activity_bloc.dart';
import 'package:buoy/locate/repository/background_location_repository.dart';
import 'package:buoy/motion/bloc/motion_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';

part 'geolocation_event.dart';
part 'geolocation_state.dart';

class GeolocationBloc extends Bloc<GeolocationEvent, GeolocationState> {
  final BackgroundLocationRepository _backgroundLocationRepository;
  final ActivityBloc _activityBloc;
  final MotionBloc _motionBloc;
  GeolocationBloc(
      {required BackgroundLocationRepository backgroundLocationRepository,
      required ActivityBloc activityBloc,
      required MotionBloc motionBloc})
      : _backgroundLocationRepository = backgroundLocationRepository,
        _activityBloc = activityBloc,
        _motionBloc = motionBloc,
        super(GeolocationInitial()) {
    on<LoadGeolocation>(_onLoadGeolocation);
    on<UpdateGeoLocation>(_onUpdateGeoLocation);
  }

  void _onLoadGeolocation(
    LoadGeolocation event,
    Emitter<GeolocationState> emit,
  ) async {
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
    emit(GeolocationLoading());

    /// Initialize BackgroundGeolocation
    await _backgroundLocationRepository.initBackgroundGeolocation();

    /// Initial location fetch
    bg.Location location =
        await _backgroundLocationRepository.getCurrentLocation();

    print('Initial location: $location');
    _backgroundLocationRepository.onLocationChange((bg.Location location) {
      print('[initial location changed] - $location');
      add(UpdateGeoLocation(location: location));
    });

    /// Update activity bloc
    _activityBloc.add(LoadActivity(activity: location.activity.type));
    // _motionBloc.add(LoadMotion(isMoving: location.isMoving));
    emit(GeolocationLoaded(location: location));
  }

  void _onUpdateGeoLocation(
    UpdateGeoLocation event,
    Emitter<GeolocationState> emit,
  ) {
    emit(GeolocationUpdating(location: event.location));
    emit(GeolocationLoaded(location: event.location));
    _backgroundLocationRepository.onLocationChange((bg.Location location) {
      print('[location updated] - $location');
      add(UpdateGeoLocation(location: location));
    });
  }
}
