part of 'activity_bloc.dart';

@immutable
abstract class ActivityState extends Equatable {
  final String? activity;
  const ActivityState({
    this.activity,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [activity];
}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  @override
  final String activity;
  const ActivityLoaded({
    required this.activity,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [activity];
}

class ActivityError extends ActivityState {
  final String message;
  const ActivityError({
    required this.message,
  });
}

class ActivityDenied extends ActivityState {
  final String message;
  const ActivityDenied({
    required this.message,
  });
}
