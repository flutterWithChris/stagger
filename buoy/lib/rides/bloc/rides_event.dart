part of 'rides_bloc.dart';

sealed class RidesEvent extends Equatable {
  const RidesEvent();

  @override
  List<Object> get props => [];
}

class LoadRides extends RidesEvent {}
