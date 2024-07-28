import 'package:bloc/bloc.dart';
import 'package:buoy/auth/repository/auth_repository.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart' as supabase;

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final AuthRepository _authRepository;
  SignupCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(SignupState.initial());

  void signupWithGoogle() => _onSignupWithGoogle();

  void _onSignupWithGoogle() async {
    emit(SignupState.submitting());
    await _authRepository.signInWithGoogle();
    _authRepository.authStateChanges.listen((state) {
      if (state.session?.user == null) {
        print('User is null');
        emit(SignupState.failure());
      } else {
        print('Signup success');
        emit(SignupState.success(state.session!.user));
      }
    });
  }
}
