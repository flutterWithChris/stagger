part of 'ride_bloc.dart';

sealed class RideState extends Equatable {
  final Ride? ride;
  final List<double>? meetingPoint;
  const RideState({
    this.ride,
    this.meetingPoint,
  });

  @override
  List<Object?> get props => [
        ride,
        meetingPoint,
      ];
}

final class RideInitial extends RideState {}

final class RideLoading extends RideState {}

final class RideLoaded extends RideState {
  @override
  final Ride ride;

  const RideLoaded(this.ride);

  @override
  List<Object> get props => [ride];
}

final class RideUpdated extends RideState {
  @override
  final Ride ride;

  const RideUpdated({required this.ride});

  @override
  List<Object> get props => [ride];
}

final class CreatingRide extends RideState {
  @override
  final Ride ride;

  const CreatingRide(this.ride);

  @override
  List<Object> get props => [ride];
}

final class RideCreated extends RideState {
  @override
  final Ride ride;

  const RideCreated(this.ride);

  @override
  List<Object> get props => [ride];
}

final class RideRequestSent extends RideState {
  @override
  final Ride ride;

  const RideRequestSent(this.ride);

  @override
  List<Object> get props => [ride];
}

final class RideError extends RideState {
  @override
  final Ride? ride;
  @override
  final String error;

  const RideError(this.error, {this.ride});

  @override
  List<Object?> get props => [error, ride];
}

final class RideCompleted extends RideState {
  @override
  final Ride ride;

  const RideCompleted(this.ride);

  @override
  List<Object> get props => [ride];
}

final class RideCancelled extends RideState {
  @override
  final Ride ride;

  const RideCancelled(this.ride);

  @override
  List<Object> get props => [ride];
}

final class RideDeclined extends RideState {
  @override
  final Ride ride;

  const RideDeclined(this.ride);

  @override
  List<Object> get props => [ride];
}

final class RideAccepted extends RideState {
  @override
  final Ride ride;

  const RideAccepted(this.ride);

  @override
  List<Object> get props => [ride];
}

final class JoinedRide extends RideState {
  @override
  final Ride ride;

  const JoinedRide(this.ride);

  @override
  List<Object> get props => [ride];
}

final class SelectingMeetingPoint extends RideState {
  @override
  final Ride ride;
  @override
  final List<double>? meetingPoint;

  const SelectingMeetingPoint(this.ride, {this.meetingPoint});

  @override
  List<Object?> get props => [ride, meetingPoint];
}
