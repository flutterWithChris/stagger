class Location {
  String userId;
  String latitude;
  String longitude;
  String timeStamp;
  int? batteryLevel;
  String? activity;
  bool? isMoving;

  Location({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.timeStamp,
    this.batteryLevel,
    this.activity,
    this.isMoving,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      userId: json['user_id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      timeStamp: json['timeStamp'],
      batteryLevel: json['battery_level'],
      activity: json['activity'],
      isMoving: json['is_moving'],
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'timeStamp': timeStamp,
        'battery_level': batteryLevel,
        'activity': activity,
        'is_moving': isMoving,
      };
}
