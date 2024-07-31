import 'package:latlong2/latlong.dart';

enum RideStatus {
  pending,
  accepted,
  inProgress,
  rejected,
  rejectedWithResponse,
  canceled,
  completed
}

enum ArrivalStatus { stopped, enRoute, atMeetingPoint, atDestination }

class Ride {
  final String? id;
  final List<String>? senderIds;
  final List<String>? receiverIds;
  final RideStatus? status;
  final List<double>? meetingPoint;
  final String? meetingPointName;
  final String? meetingPointAddress;
  final List<double>? destination;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Ride({
    this.id,
    this.senderIds,
    this.receiverIds,
    this.status,
    this.meetingPoint,
    this.meetingPointName,
    this.meetingPointAddress,
    this.destination,
    this.createdAt,
    this.updatedAt,
  });

  Ride copyWith({
    String? id,
    List<String>? senderIds,
    List<String>? receiverIds,
    RideStatus? status,
    List<double>? meetingPoint,
    String? meetingPointName,
    String? meetingPointAddress,
    List<double>? destination,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Ride(
      id: id ?? this.id,
      senderIds: senderIds ?? this.senderIds,
      receiverIds: receiverIds ?? this.receiverIds,
      status: status ?? this.status,
      meetingPoint: meetingPoint ?? this.meetingPoint,
      meetingPointName: meetingPointName ?? this.meetingPointName,
      meetingPointAddress: meetingPointAddress ?? this.meetingPointAddress,
      destination: destination ?? this.destination,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status ?? RideStatus.pending.name.toString(),
      'meeting_point': meetingPoint,
      'meeting_point_name': meetingPointName,
      'meeting_point_address': meetingPointAddress,
      'destination': destination,
    };
  }

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
      id: map['id'],
      status: RideStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RideStatus.pending,
      ),
      meetingPoint: map['meeting_point'] == null
          ? null
          : List<double>.from(map['meeting_point']),
      meetingPointName: map['meeting_point_name'],
      meetingPointAddress: map['meeting_point_address'],
      destination: map['destination'] == null
          ? null
          : List<double>.from(map['destination']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride.fromMap(json);
  }

  Map<String, dynamic> toJson() => toMap();

  @override
  String toString() {
    return 'Ride(id: $id, senderIds: $senderIds, receiverIds: $receiverIds, status: $status, meetingPoint: $meetingPoint, meetingPointName: $meetingPointName, meetingPointAddress: $meetingPointAddress destination: $destination, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Ride &&
        other.id == id &&
        other.senderIds == senderIds &&
        other.receiverIds == receiverIds &&
        other.status == status &&
        other.meetingPoint == meetingPoint &&
        other.destination == destination &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }
}
