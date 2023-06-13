import 'package:bloc/bloc.dart';
import 'package:buoy/auth/repository/auth_repository.dart';
import 'package:meta/meta.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;
  LoginCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(LoginInitial());
  Future<void> loginWithGoogle() => _onLoginWithGoogle();
  Future<void> loginWithApple() => _onLoginWithApple();
  Future<void> _onLoginWithGoogle() async {
    emit(LoginLoading());
    try {
      await _authRepository.signInWithGoogle();
      _authRepository.getAuthStateStream().listen((authState) {
        if (authState.session?.user == null) {
          print('User is null');
          emit(LoginError('User is null'));
        } else {
          print('Signup success');
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
      _authRepository.getAuthStateStream().listen((event) {
        if (event.session?.user == null) {
          print('User is null');
          emit(LoginError('User is null'));
        } else {
          print('Signup success');
          emit(LoginSuccess());
        }
      });
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}
