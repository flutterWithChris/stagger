import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:supabase_flutter/supabase_flutter.dart';

class Location {
  String userId;
  String latitude;
  String longitude;
  String timeStamp;
  String? locationString;
  String? city;
  String? state;
  int? batteryLevel;
  String? activity;
  bool? isMoving;

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
  });

  // CopyWith
  Location copyWith({
    String? userId,
    String? latitude,
    String? longitude,
    String? locationString,
    String? city,
    String? state,
    String? timeStamp,
    int? batteryLevel,
    String? activity,
    bool? isMoving,
  }) {
    return Location(
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationString: locationString ?? this.locationString,
      city: city ?? this.city,
      state: state ?? this.state,
      timeStamp: timeStamp ?? this.timeStamp,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      activity: activity ?? this.activity,
      isMoving: isMoving ?? this.isMoving,
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
    );
  }

  factory Location.fromBGLocation(bg.Location location) {
    return Location(
      userId: Supabase.instance.client.auth.currentUser!.id,
      latitude: location.coords.latitude.toString(),
      longitude: location.coords.longitude.toString(),
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
        'city': city,
        'state': state,
        'timeStamp': timeStamp,
        'battery_level': batteryLevel,
        'activity': activity,
        'is_moving': isMoving,
      };
}
