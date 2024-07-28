part of 'geolocation_bloc.dart';

@immutable
abstract class GeolocationState extends Equatable {
  final bg.Location? bgLocation;
  final Location? location;
  const GeolocationState({
    this.bgLocation,
    this.location,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [bgLocation];
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
  final Location location;
  const GeolocationLoaded({
    required this.bgLocation,
    required this.location,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [bgLocation];
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
