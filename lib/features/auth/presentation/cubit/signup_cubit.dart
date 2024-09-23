import 'package:bloc/bloc.dart';
import 'package:buoy/features/auth/data/repository/auth_repository_impl.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart' as supabase;

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final AuthRepositoryImpl _authRepository;
  SignupCubit({required AuthRepositoryImpl authRepository})
      : _authRepository = authRepository,
        super(SignupState.initial());

  void signUpWithGoogle() => _onSignUpWithGoogle();
  void signUpWithApple() => _onSignUpWithApple();

  void _onSignUpWithGoogle() async {
    emit(SignupState.submitting());
    await _authRepository.signInWithGoogle();
    _authRepository.authStateChanges.listen((state) {
      if (state.session?.user == null) {
        emit(SignupState.failure());
      } else {
        emit(SignupState.success(state.session!.user));
      }
    });
  }

  void _onSignUpWithApple() async {
    emit(SignupState.submitting());
    await _authRepository.signInWithApple();
    _authRepository.authStateChanges.listen((state) {
      if (state.session?.user == null) {
        emit(SignupState.failure());
      } else {
        emit(SignupState.success(state.session!.user));
      }
    });
  }
}
