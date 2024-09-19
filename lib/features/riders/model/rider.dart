import 'package:buoy/features/locate/model/location.dart';
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

enum RidingStyle { cruiser, balanced, fast }

enum RideType { offRoad, backroads, touring, rally, adventure, downtown, track }

enum LocationStatus { sharing, notSharing, notAvailable }

enum GearLevel { none, some, atgatt }

enum RideDestination {
  cafes,
  food,
  scenicViews,
  bars,
  breweries,
  parks,
  campgrounds,
  iceCream,
  tracks,
  wineries,
  events,
  bikeNights,
  carShows,
}

class Rider extends User {
  final BikeType? bikeType;
  final String? bike;
  final RidingStyle? ridingStyle;
  final List<RideType>? rideTypes;
  final List<RideDestination>? rideDestinations;
  final GearLevel? gearLevel;
  final int? yearsRiding;
  final Location? currentLocation;
  final LocationStatus? locationStatus;

  Rider({
    super.id,
    super.firstName,
    super.lastName,
    super.email,
    this.bikeType,
    this.bike,
    this.ridingStyle,
    this.rideTypes,
    this.rideDestinations,
    this.gearLevel,
    this.yearsRiding,
    this.currentLocation,
    this.locationStatus,
  });

  // toJson
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bike_type': bikeType?.toString().split('.').last,
      'bike': bike,
      'riding_style': ridingStyle?.toString().split('.').last,
      'ride_types':
          rideTypes?.map((e) => e.toString().split('.').last).toList(),
      'ride_destinations':
          rideDestinations?.map((e) => e.toString().split('.').last).toList(),
      'gear_level': gearLevel?.toString().split('.').last,
      'years_riding': yearsRiding,
      'location_status': locationStatus?.toString().split('.').last,
    };
  }

  // fromMAp
  factory Rider.fromMap(Map<String, dynamic> map) {
    return Rider(
      id: map['id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      email: map['email'],
      bikeType: BikeType.values.firstWhereOrNull(
          (e) => e.toString().split('.').last == map['bike_type']),
      bike: map['bike'],
      ridingStyle: RidingStyle.values.firstWhereOrNull(
          (e) => e.toString().split('.').last == map['riding_style']),
      rideDestinations: List<RideDestination>.from(map['ride_destinations']
              ?.map((e) => RideDestination.values
                  .firstWhere((r) => r.toString().split('.').last == e)) ??
          []),
      gearLevel: GearLevel.values.firstWhereOrNull(
          (e) => e.toString().split('.').last == map['gear_level']),
      yearsRiding: map['years_riding'],
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
    String? firstName,
    String? lastName,
    String? email,
    List<String>? friendIds,
    String? photoUrl,
    BikeType? bikeType,
    String? bike,
    RidingStyle? ridingStyle,
    List<RideDestination>? rideDestinations,
    GearLevel? gearLevel,
    int? yearsRiding,
    List<RideType>? rideTypes,
    Location? currentLocation,
    LocationStatus? locationStatus,
  }) {
    return Rider(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      bikeType: bikeType ?? this.bikeType,
      bike: bike ?? this.bike,
      ridingStyle: ridingStyle ?? this.ridingStyle,
      rideDestinations: rideDestinations ?? this.rideDestinations,
      gearLevel: gearLevel ?? this.gearLevel,
      yearsRiding: yearsRiding ?? this.yearsRiding,
      rideTypes: rideTypes ?? this.rideTypes,
      currentLocation: currentLocation ?? this.currentLocation,
      locationStatus: locationStatus ?? this.locationStatus,
    );
  }

  // toString override
  @override
  toString() {
    return 'Rider{id: $id, firstName: $firstName, lastName: $lastName, email: $email, bikeType: $bikeType, bike: $bike, ridingStyle: $ridingStyle, rideDestinations: $rideDestinations, gearLevel: $gearLevel, yearsRiding: $yearsRiding, rideTypes: $rideTypes, currentLocation: $currentLocation, locationStatus: $locationStatus}';
  }
}
