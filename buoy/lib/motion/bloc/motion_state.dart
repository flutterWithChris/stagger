part of 'motion_bloc.dart';

@immutable
abstract class MotionState extends Equatable {
  final bool? isMoving;
  const MotionState({
    this.isMoving,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [isMoving];
}

class MotionInitial extends MotionState {}

class MotionLoading extends MotionState {}

class MotionLoaded extends MotionState {
  @override
  final bool isMoving;
  const MotionLoaded({
    required this.isMoving,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [isMoving];
}

class MotionError extends MotionState {
  final String message;
  const MotionError({
    required this.message,
  });
}
