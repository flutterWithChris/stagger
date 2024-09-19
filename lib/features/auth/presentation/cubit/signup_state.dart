part of 'signup_cubit.dart';

enum SignupStatus { initial, submitting, success, failure }

@immutable
class SignupState {
  final SignupStatus status;
  final supabase.User? user;
  final String? firstName;
  final String? lastName;
  const SignupState({
    required this.status,
    this.firstName,
    this.lastName,
    this.user,
  });

  factory SignupState.initial() {
    return const SignupState(
      status: SignupStatus.initial,
    );
  }

  factory SignupState.submitting() {
    return const SignupState(
      status: SignupStatus.submitting,
    );
  }

  factory SignupState.success(supabase.User user,
      {String? firstName, String? lastName}) {
    return SignupState(
      status: SignupStatus.success,
      user: user,
      firstName: firstName,
      lastName: lastName,
    );
  }

  factory SignupState.failure() {
    return const SignupState(
      status: SignupStatus.failure,
    );
  }
}
