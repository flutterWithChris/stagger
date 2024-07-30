part of 'ride_bloc.dart';

sealed class RideState extends Equatable {
  final Ride? ride;
  const RideState({
    this.ride,
  });

  @override
  List<Object?> get props => [
        ride,
      ];
}

final class RideInitial extends RideState {}

final class RideLoading extends RideState {}

final class RideLoaded extends RideState {
  @override
  final List<Ride> rides;

  const RideLoaded(this.rides);

  @override
  List<Object> get props => [rides];
}

final class RideUpdated extends RideState {
  @override
  final Ride ride;

  const RideUpdated(this.ride);

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
