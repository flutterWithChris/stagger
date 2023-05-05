part of 'activity_bloc.dart';

@immutable
abstract class ActivityEvent extends Equatable {
  final String? activity;
  const ActivityEvent({
    this.activity,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [activity];
}

class LoadActivity extends ActivityEvent {
  @override
  final String activity;
  const LoadActivity({
    required this.activity,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [activity];
}

class UpdateActivity extends ActivityEvent {
  @override
  final String activity;
  const UpdateActivity({
    required this.activity,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [activity];
}
