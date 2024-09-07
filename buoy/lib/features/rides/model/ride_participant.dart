import 'package:buoy/features/rides/model/ride.dart';
import 'package:collection/collection.dart';

enum ParticipationStatus { pending, accepted, rejected, host }

class RideParticipant {
  final String? id;
  final String? rideId;
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? role;
  final String? photoUrl;
  final ArrivalStatus? arrivalStatus;
  final ParticipationStatus? participationStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RideParticipant({
    this.id,
    this.rideId,
    this.userId,
    this.firstName,
    this.lastName,
    this.role,
    this.photoUrl,
    this.arrivalStatus,
    this.participationStatus,
    this.createdAt,
    this.updatedAt,
  });

  RideParticipant copyWith({
    String? id,
    String? rideId,
    String? userId,
    String? firstName,
    String? lastName,
    String? role,
    String? photoUrl,
    ArrivalStatus? arrivalStatus,
    ParticipationStatus? participationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RideParticipant(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      arrivalStatus: arrivalStatus ?? this.arrivalStatus,
      participationStatus: participationStatus ?? this.participationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ride_id': rideId,
      'user_id': userId,
      'role': role,
      'arrival_status': arrivalStatus?.name,
      'participation_status': participationStatus?.name,
    };
  }

  factory RideParticipant.fromMap(Map<String, dynamic> map) {
    return RideParticipant(
      id: map['id'],
      rideId: map['ride_id'],
      userId: map['user_id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      role: map['role'],
      photoUrl: map['photo_url'],
      arrivalStatus: map['arrival_status'] != null
          ? ArrivalStatus.values
              .firstWhereOrNull((e) => e.name == map['arrival_status'])
          : null,
      participationStatus: map['participation_status'] != null
          ? ParticipationStatus.values
              .firstWhereOrNull((e) => e.name == map['participation_status'])
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
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.role == role &&
        other.arrivalStatus == arrivalStatus &&
        other.participationStatus == participationStatus &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        rideId.hashCode ^
        userId.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        role.hashCode ^
        arrivalStatus.hashCode ^
        participationStatus.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  // toString() method
  @override
  String toString() {
    return 'RideParticipant(id: $id, rideId: $rideId, userId: $userId, firstName: $firstName, lastName: $lastName, role: $role, photoUrl: $photoUrl, arrivalStatus: $arrivalStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
