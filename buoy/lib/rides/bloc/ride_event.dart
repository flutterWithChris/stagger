part of 'ride_bloc.dart';

sealed class RideEvent extends Equatable {
  const RideEvent();

  @override
  List<Object> get props => [];
}

class CreateRide extends RideEvent {
  final Ride ride;

  const CreateRide(this.ride);

  @override
  List<Object> get props => [ride];
}

class SendRideRequest extends RideEvent {
  final Ride ride;

  const SendRideRequest(this.ride);

  @override
  List<Object> get props => [ride];
}

class CancelRide extends RideEvent {
  final Ride ride;

  const CancelRide(this.ride);

  @override
  List<Object> get props => [ride];
}

class AcceptRide extends RideEvent {
  final Ride ride;

  const AcceptRide(this.ride);

  @override
  List<Object> get props => [ride];
}

class DeclineRide extends RideEvent {
  final Ride ride;

  const DeclineRide(this.ride);

  @override
  List<Object> get props => [ride];
}

class UpdateRide extends RideEvent {
  final Ride ride;

  const UpdateRide(this.ride);

  @override
  List<Object> get props => [ride];
}

class UpdateRideDraft extends RideEvent {
  final Ride ride;

  const UpdateRideDraft(this.ride);

  @override
  List<Object> get props => [ride];
}

class UpdateArrivalStatus extends RideEvent {
  final Ride ride;
  final String userId;
  final ArrivalStatus arrivalStatus;

  const UpdateArrivalStatus(
      {required this.ride, required this.userId, required this.arrivalStatus});

  @override
  List<Object> get props => [ride, userId, arrivalStatus];
}
