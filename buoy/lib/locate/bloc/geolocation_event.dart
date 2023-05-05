part of 'geolocation_bloc.dart';

@immutable
abstract class GeolocationEvent {}

class LoadGeolocation extends GeolocationEvent {}

class UpdateGeoLocation extends GeolocationEvent {
  final bg.Location location;
  UpdateGeoLocation({
    required this.location,
  });
}
