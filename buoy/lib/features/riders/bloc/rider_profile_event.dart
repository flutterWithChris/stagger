part of 'rider_profile_bloc.dart';

sealed class RiderProfileEvent extends Equatable {
  const RiderProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadRiderProfile extends RiderProfileEvent {
  final Rider? rider;
  final String? riderId;

  const LoadRiderProfile({this.rider, this.riderId});

  @override
  List<Object?> get props => [rider, riderId];
}
