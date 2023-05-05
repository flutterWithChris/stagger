part of 'motion_bloc.dart';

@immutable
abstract class MotionEvent extends Equatable {
  final bool? isMoving;
  const MotionEvent({
    this.isMoving,
  });
}

class LoadMotion extends MotionEvent {
  @override
  final bool isMoving;
  const LoadMotion({
    required this.isMoving,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [isMoving];
}

class UpdateMotion extends MotionEvent {
  @override
  final bool isMoving;
  const UpdateMotion({
    required this.isMoving,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [isMoving];
}
