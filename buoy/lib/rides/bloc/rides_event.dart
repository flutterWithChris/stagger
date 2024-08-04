part of 'rides_bloc.dart';

sealed class RidesEvent extends Equatable {
  const RidesEvent();

  @override
  List<Object> get props => [];
}

class LoadRides extends RidesEvent {
  final List<RideParticipant> rideParticipants;

  const LoadRides(this.rideParticipants);

  @override
  List<Object> get props => [rideParticipants];
}

class FetchRiders extends RidesEvent {
  final List<Ride> myRides;
  final List<Ride> receivedRides;

  const FetchRiders(this.myRides, this.receivedRides);

  @override
  List<Object> get props => [myRides, receivedRides];
}
