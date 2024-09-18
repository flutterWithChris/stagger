part of 'coach_marks_cubit.dart';

sealed class CoachMarksState extends Equatable {
  const CoachMarksState();

  @override
  List<Object> get props => [];
}

final class CoachMarksInitial extends CoachMarksState {}

final class CoachMarksLoading extends CoachMarksState {}

final class CoachMarksLoaded extends CoachMarksState {
  final bool fabCoachmarkShown;

  const CoachMarksLoaded(this.fabCoachmarkShown);

  @override
  List<Object> get props => [fabCoachmarkShown];
}
