import 'package:buoy/rides/model/ride.dart';
import 'package:collection/collection.dart';

class RideParticipant {
  final String? id;
  final String? rideId;
  final String? userId;
  final String? name;
  final String? role;
  final ArrivalStatus? arrivalStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RideParticipant({
    this.id,
    this.rideId,
    this.userId,
    this.name,
    this.role,
    this.arrivalStatus,
    this.createdAt,
    this.updatedAt,
  });

  RideParticipant copyWith({
    String? id,
    String? rideId,
    String? userId,
    String? name,
    String? role,
    ArrivalStatus? arrivalStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RideParticipant(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      role: role ?? this.role,
      arrivalStatus: arrivalStatus ?? this.arrivalStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ride_id': rideId,
      'user_id': userId,
      'name': name,
      'role': role,
      'arrival_status': arrivalStatus?.name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory RideParticipant.fromMap(Map<String, dynamic> map) {
    return RideParticipant(
      id: map['id'],
      rideId: map['ride_id'],
      userId: map['user_id'],
      name: map['name'],
      role: map['role'],
      arrivalStatus: map['arrival_status'] != null
          ? ArrivalStatus.values
              .firstWhereOrNull((e) => e.name == map['arrival_status'])
          : null,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RideParticipant &&
        other.id == id &&
        other.rideId == rideId &&
        other.userId == userId &&
        other.name == name &&
        other.role == role &&
        other.arrivalStatus == arrivalStatus &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }
}
