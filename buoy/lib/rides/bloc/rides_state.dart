part of 'rides_bloc.dart';

sealed class RidesState extends Equatable {
  final List<Ride>? myRides;
  final List<Ride>? receivedRides;
  final List<RideParticipant>? allParticipants;
  const RidesState({
    this.myRides,
    this.receivedRides,
    this.allParticipants,
  });

  @override
  List<Object?> get props => [
        myRides,
        receivedRides,
        allParticipants,
      ];
}

final class RidesInitial extends RidesState {}

final class RidesLoading extends RidesState {}

final class RidesLoaded extends RidesState {
  @override
  final List<Ride> myRides;
  @override
  final List<Ride> receivedRides;
  @override
  final List<RideParticipant> allParticipants;

  const RidesLoaded(this.myRides, this.receivedRides, this.allParticipants);

  @override
  List<Object> get props => [myRides, receivedRides, allParticipants];
}

final class RidesError extends RidesState {
  final String error;

  const RidesError(this.error);

  @override
  List<Object> get props => [error];
}
