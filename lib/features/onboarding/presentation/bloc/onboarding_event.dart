part of 'onboarding_bloc.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

final class StartOnboarding extends OnboardingEvent {
  final sb.User user;

  const StartOnboarding({required this.user});
}

final class UpdateUser extends OnboardingEvent {
  final User user;

  const UpdateUser({required this.user});
}

final class CreateRider extends OnboardingEvent {
  final User user;

  const CreateRider({required this.user});
}

final class UpdateRider extends OnboardingEvent {
  final User user;
  final Rider rider;

  const UpdateRider({required this.user, required this.rider});
}

final class SetCanMoveForward extends OnboardingEvent {
  final bool canMoveForward;

  const SetCanMoveForward(this.canMoveForward);
}

final class SetCanMoveForwardCallback extends OnboardingEvent {
  final Function() callback;

  const SetCanMoveForwardCallback(this.callback);
}

final class MoveForward extends OnboardingEvent {
  const MoveForward();
}
