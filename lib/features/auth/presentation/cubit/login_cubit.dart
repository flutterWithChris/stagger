import 'package:bloc/bloc.dart';
import 'package:buoy/features/auth/data/repository/auth_repository_impl.dart';
import 'package:meta/meta.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepositoryImpl _authRepository;
  LoginCubit({required AuthRepositoryImpl authRepository})
      : _authRepository = authRepository,
        super(LoginInitial());
  Future<void> loginWithGoogle() => _onLoginWithGoogle();
  Future<void> loginWithApple() => _onLoginWithApple();
  Future<void> _onLoginWithGoogle() async {
    emit(LoginLoading());
    try {
      await _authRepository.signInWithGoogle();
      _authRepository.authStateChanges.listen((authState) {
        if (authState.session?.user == null) {
          emit(LoginError('User is null'));
        } else {

          emit(LoginSuccess());
        }
      });
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }

  Future<void> _onLoginWithApple() async {
    emit(LoginLoading());
    try {
      await _authRepository.signInWithApple();
      _authRepository.authStateChanges.listen((event) {
        if (event.session?.user == null) {
          emit(LoginError('User is null'));
        } else {
          emit(LoginSuccess());
        }
      });
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}
