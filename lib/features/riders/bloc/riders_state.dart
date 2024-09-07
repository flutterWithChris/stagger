part of 'riders_bloc.dart';

sealed class RidersState extends Equatable {
  final List<Rider>? riders;
  const RidersState({this.riders});

  @override
  List<Object?> get props => [riders];
}

final class RidersInitial extends RidersState {}

final class RidersLoading extends RidersState {}

final class RidersLoaded extends RidersState {
  @override
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
