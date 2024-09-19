part of 'geolocation_bloc.dart';

@immutable
abstract class GeolocationState extends Equatable {
  final bg.Location? bgLocation;
  final Location? location;
  final bool? locationUpdatesEnabled;
  const GeolocationState({
    this.bgLocation,
    this.location,
    this.locationUpdatesEnabled,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [bgLocation, location, locationUpdatesEnabled];
}

class GeolocationInitial extends GeolocationState {}

class GeolocationLoading extends GeolocationState {}

class GeolocationUpdating extends GeolocationState {
  @override
  final bg.Location bgLocation;
  const GeolocationUpdating({
    required this.bgLocation,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [bgLocation];
}

class GeolocationLoaded extends GeolocationState {
  @override
  final bg.Location bgLocation;
  @override
  final Location? location;
  @override
  final bool? locationUpdatesEnabled;
  const GeolocationLoaded(
      {required this.bgLocation, this.location, this.locationUpdatesEnabled});

  @override
  // TODO: implement props
  List<Object?> get props => [bgLocation, location, locationUpdatesEnabled];
}

class GeolocationError extends GeolocationState {
  final String message;
  const GeolocationError({
    required this.message,
  });
}

class GeolocationDenied extends GeolocationState {
  final String message;
  const GeolocationDenied({
    required this.message,
  });
}

class GeolocationStopped extends GeolocationState {}
