part of 'riders_bloc.dart';

sealed class RidersEvent extends Equatable {
  final LatLngBounds? bounds;
  const RidersEvent({this.bounds});

  @override
  List<Object?> get props => [bounds];
}

final class LoadRiders extends RidersEvent {
  @override
  final LatLngBounds bounds;

  const LoadRiders(this.bounds);

  @override
  List<Object?> get props => [bounds];
}
