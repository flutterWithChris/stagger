import 'package:buoy/locate/model/location.dart';
import 'package:buoy/shared/models/user.dart';
import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';

enum BikeType {
  sport,
  cruiser,
  touring,
  adventure,
  cafeRacer,
  dirt,
  dualSport,
  scooter
}

enum RidingStyle { aggressive, casual }

enum RideType { any, offRoad, longTrip, downtown, track }

enum LocationStatus { sharing, notSharing, notAvailable }

class Rider extends User {
  final BikeType? bikeType;
  final RidingStyle? ridingStyle;
  final List<RideType>? rideTypes;
  final Location? currentLocation;
  final LocationStatus? locationStatus;

  Rider({
    super.id,
    super.name,
    super.email,
    this.bikeType,
    this.ridingStyle,
    this.rideTypes,
    this.currentLocation,
    this.locationStatus,
  });

  // toJson
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bike_type': bikeType?.toString().split('.').last,
      'riding_style': ridingStyle?.toString().split('.').last,
      'ride_types':
          rideTypes?.map((e) => e.toString().split('.').last).toList(),
      'location_status': locationStatus?.toString().split('.').last,
    };
  }

  // fromMAp
  factory Rider.fromMap(Map<String, dynamic> map) {
    return Rider(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      bikeType: BikeType.values.firstWhereOrNull(
          (e) => e.toString().split('.').last == map['bike_type']),
      ridingStyle: RidingStyle.values.firstWhereOrNull(
          (e) => e.toString().split('.').last == map['riding_style']),
      rideTypes: List<RideType>.from(map['ride_types']?.map((e) => RideType
              .values
              .firstWhere((r) => r.toString().split('.').last == e)) ??
          []),
      locationStatus: LocationStatus.values.firstWhereOrNull(
          (e) => e.toString().split('.').last == map['location_status']),
    );
  }

  // copyWith
  @override
  Rider copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? friendIds,
    String? photoUrl,
    BikeType? bikeType,
    RidingStyle? ridingStyle,
    List<RideType>? rideTypes,
    Location? currentLocation,
    LocationStatus? locationStatus,
  }) {
    return Rider(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      bikeType: bikeType ?? this.bikeType,
      ridingStyle: ridingStyle ?? this.ridingStyle,
      rideTypes: rideTypes ?? this.rideTypes,
      currentLocation: currentLocation ?? this.currentLocation,
      locationStatus: locationStatus ?? this.locationStatus,
    );
  }
}
