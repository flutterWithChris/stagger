part of 'riders_bloc.dart';

sealed class RidersState extends Equatable {
  const RidersState();

  @override
  List<Object> get props => [];
}

final class RidersInitial extends RidersState {}

final class RidersLoading extends RidersState {}

final class RidersLoaded extends RidersState {
  final List<Rider> riders;

  const RidersLoaded(this.riders);

  @override
  List<Object> get props => [riders];
}

final class RidersError extends RidersState {
  final String message;

  const RidersError(this.message);

  @override
  List<Object> get props => [message];
}
