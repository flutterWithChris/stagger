part of 'rider_profile_bloc.dart';

sealed class RiderProfileState extends Equatable {
  const RiderProfileState();

  @override
  List<Object> get props => [];
}

final class RiderProfileInitial extends RiderProfileState {}

final class RiderProfileLoading extends RiderProfileState {}

final class RiderProfileError extends RiderProfileState {
  final String message;

  const RiderProfileError(this.message);

  @override
  List<Object> get props => [message];
}

final class RiderProfileLoaded extends RiderProfileState {
  final Rider rider;

  const RiderProfileLoaded(this.rider);

  @override
  List<Object> get props => [rider];
}
