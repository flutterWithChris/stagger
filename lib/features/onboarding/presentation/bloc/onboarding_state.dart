part of 'onboarding_bloc.dart';

sealed class OnboardingState extends Equatable {
  final User? user;
  final Rider? rider;
  const OnboardingState({this.user, this.rider});

  @override
  List<Object?> get props => [rider];
}

final class OnboardingInitial extends OnboardingState {}

final class OnboardingLoading extends OnboardingState {}

final class OnboardingLoaded extends OnboardingState {
  final bool isOnboardingComplete;
  @override
  final User user;
  @override
  final Rider rider;

  const OnboardingLoaded(
      {required this.isOnboardingComplete,
      required this.user,
      required this.rider});

  @override
  List<Object?> get props => [isOnboardingComplete, user, rider];
}

final class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError({required this.message});

  @override
  List<Object> get props => [message];
}

final class UserUpdated extends OnboardingState {
  @override
  final User user;

  const UserUpdated({required this.user});

  @override
  List<Object> get props => [user];
}

final class RiderUpdated extends OnboardingState {
  @override
  final Rider rider;

  const RiderUpdated({required this.rider});

  @override
  List<Object> get props => [rider];
}
