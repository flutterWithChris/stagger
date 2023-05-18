part of 'signup_cubit.dart';

enum SignupStatus { initial, submitting, success, failure }

@immutable
class SignupState {
  final SignupStatus status;
  final supabase.User? user;
  const SignupState({
    required this.status,
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

  factory SignupState.success(supabase.User user) {
    return SignupState(
      status: SignupStatus.success,
      user: user,
    );
  }

  factory SignupState.failure() {
    return const SignupState(
      status: SignupStatus.failure,
    );
  }
}
