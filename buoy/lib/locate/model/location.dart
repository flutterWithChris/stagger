import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:supabase_flutter/supabase_flutter.dart';

class Location {
  String userId;
  double? latitude;
  double? longitude;
  String timeStamp;
  String? locationString;
  String? city;
  String? state;
  int? batteryLevel;
  String? activity;
  bool? isMoving;
  double? heading;

  Location({
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.locationString,
    this.city,
    this.state,
    required this.timeStamp,
    this.batteryLevel,
    this.activity,
    this.isMoving,
    this.heading,
  });

  // CopyWith
  Location copyWith({
    String? userId,
    double? latitude,
    double? longitude,
    String? locationString,
    String? city,
    String? state,
    String? timeStamp,
    int? batteryLevel,
    String? activity,
    bool? isMoving,
    bool? includeNull,
    double? heading,
  }) {
    return Location(
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationString: locationString ?? this.locationString,
      city: city ?? this.city,
      state: state ?? this.state,
      timeStamp: timeStamp ?? this.timeStamp,
      batteryLevel: includeNull == true
          ? batteryLevel
          : batteryLevel ?? this.batteryLevel,
      activity: includeNull == true ? activity : activity ?? this.activity,
      isMoving: includeNull == true ? isMoving : isMoving ?? this.isMoving,
      heading: heading ?? this.heading,
    );
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      userId: json['user_id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      locationString: json['location_string'],
      city: json['city'],
      state: json['state'],
      timeStamp: json['timeStamp'],
      batteryLevel: json['battery_level'],
      activity: json['activity'],
      isMoving: json['is_moving'],
      heading: json['heading'],
    );
  }

  factory Location.fromBGLocation(bg.Location location) {
    return Location(
      userId: Supabase.instance.client.auth.currentUser!.id,
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
      heading: location.coords.heading,
      timeStamp: DateTime.now().toIso8601String(),
      batteryLevel: (location.battery.level * 100).round(),
      activity: location.activity.type,
      isMoving: location.isMoving,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'location_string': locationString,
        'heading': heading,
        'city': city,
        'state': state,
        'timeStamp': timeStamp,
        'battery_level': batteryLevel,
        'activity': activity,
        'is_moving': isMoving,
      };
}
