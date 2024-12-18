import 'package:buoy/features/rides/model/ride_participant.dart';
import 'package:latlong2/latlong.dart';

enum RideStatus {
  pending,
  meetingUp,
  inProgress,
  canceled,
  rejected,
  completed
}

enum ArrivalStatus { stopped, enRoute, atMeetingPoint, atDestination }

enum RidePrivacy { public, private }

class Ride {
  final String? id;
  final List<String>? senderIds;
  final List<String>? receiverIds;
  final RideStatus? status;
  final RidePrivacy? privacy;
  final List<double>? meetingPoint;
  final String? meetingPointName;
  final String? meetingPointAddress;
  final DateTime? meetingTime;
  final List<double>? destination;
  final String? destinationName;
  final String? destinationAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userId;
  final List<RideParticipant>? rideParticipants;
  final String? location;

  Ride({
    this.id,
    this.senderIds,
    this.receiverIds,
    this.status,
    this.privacy = RidePrivacy.public,
    this.meetingPoint,
    this.meetingPointName,
    this.meetingPointAddress,
    this.meetingTime,
    this.destination,
    this.destinationName,
    this.destinationAddress,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.rideParticipants,
    this.location,
  });

  Ride copyWith({
    String? id,
    List<String>? senderIds,
    List<String>? receiverIds,
    RideStatus? status,
    RidePrivacy? privacy,
    List<double>? meetingPoint,
    String? meetingPointName,
    String? meetingPointAddress,
    DateTime? meetingTime,
    List<double>? destination,
    String? destinationName,
    String? destinationAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    List<RideParticipant>? rideParticipants,
    String? location,
  }) {
    return Ride(
      id: id ?? this.id,
      senderIds: senderIds ?? this.senderIds,
      receiverIds: receiverIds ?? this.receiverIds,
      status: status ?? this.status,
      privacy: privacy ?? this.privacy,
      meetingPoint: meetingPoint ?? this.meetingPoint,
      meetingPointName: meetingPointName ?? this.meetingPointName,
      meetingPointAddress: meetingPointAddress ?? this.meetingPointAddress,
      meetingTime: meetingTime ?? this.meetingTime,
      destination: destination ?? this.destination,
      destinationName: destinationName ?? this.destinationName,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      rideParticipants: rideParticipants ?? this.rideParticipants,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status?.name.toString() ?? RideStatus.pending.name.toString(),
      'privacy': privacy?.name.toString() ?? RidePrivacy.public.name.toString(),
      'meeting_point': meetingPoint,
      'meeting_point_name': meetingPointName,
      'meeting_point_address': meetingPointAddress,
      'meeting_time': meetingTime,
      'destination': destination,
      'destination_name': destinationName,
      'destination_address': destinationAddress,
      'location': location,
    };
  }

  Map<String, dynamic> toSupabase() {
    return {
      'status': status?.name.toString() ?? RideStatus.pending.name.toString(),
      'privacy': privacy?.name.toString() ?? RidePrivacy.public.name.toString(),
      'meeting_point': meetingPoint,
      'meeting_point_name': meetingPointName,
      'meeting_point_address': meetingPointAddress,
      'meeting_time': meetingTime,
      'destination': destination,
      'destination_name': destinationName,
      'destination_address': destinationAddress,
      'location': location,
    };
  }

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
      id: map['id'],
      status: RideStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RideStatus.pending,
      ),
      privacy: RidePrivacy.values.firstWhere(
        (e) => e.name == map['privacy'],
        orElse: () => RidePrivacy.public,
      ),
      meetingPoint: map['meeting_point'] == null
          ? null
          : List<double>.from(map['meeting_point']),
      meetingPointName: map['meeting_point_name'],
      meetingPointAddress: map['meeting_point_address'],
      meetingTime: map['meeting_time'] == null
          ? null
          : DateTime.parse(map['meeting_time']),
      destination: map['destination'] == null
          ? null
          : List<double>.from(map['destination']),
      createdAt:
          map['created_at'] == null ? null : DateTime.parse(map['created_at']),
      updatedAt:
          map['updated_at'] == null ? null : DateTime.parse(map['updated_at']),
      userId: map['user_id'],
    );
  }

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride.fromMap(json);
  }

  Map<String, dynamic> toJson() => toMap();

  @override
  String toString() {
    return 'Ride(id: $id, senderIds: $senderIds, receiverIds: $receiverIds, status: $status, privacy: $privacy, meetingPoint: $meetingPoint, meetingPointName: $meetingPointName, meetingPointAddress: $meetingPointAddress, meetingTime: $meetingTime, destination: $destination, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Ride &&
        other.id == id &&
        other.senderIds == senderIds &&
        other.receiverIds == receiverIds &&
        other.status == status &&
        other.privacy == privacy &&
        other.meetingPoint == meetingPoint &&
        other.meetingPointName == meetingPointName &&
        other.meetingPointAddress == meetingPointAddress &&
        other.meetingTime == meetingTime &&
        other.destination == destination &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }
}
