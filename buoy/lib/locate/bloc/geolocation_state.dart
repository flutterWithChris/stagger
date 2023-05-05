part of 'geolocation_bloc.dart';

@immutable
abstract class GeolocationState extends Equatable {
  final bg.Location? location;
  const GeolocationState({
    this.location,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [location];
}

class GeolocationInitial extends GeolocationState {}

class GeolocationLoading extends GeolocationState {}

class GeolocationUpdating extends GeolocationState {
  @override
  final bg.Location location;
  const GeolocationUpdating({
    required this.location,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [location];
}

class GeolocationLoaded extends GeolocationState {
  @override
  final bg.Location location;
  const GeolocationLoaded({
    required this.location,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [location];
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
