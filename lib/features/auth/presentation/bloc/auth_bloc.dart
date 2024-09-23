import 'package:bloc/bloc.dart';
import 'package:buoy/features/auth/data/repository/auth_repository_impl.dart';
import 'package:buoy/config/router/router.dart';
import 'package:buoy/features/profile/repository/bloc/profile_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart' as supabase;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryImpl _authRepository;
  AuthBloc({
    required AuthRepositoryImpl authRepository,
  })  : _authRepository = authRepository,
        super(AuthState.initial()) {
    _authRepository.authStateChanges.listen((state) {
      if (state.session != null) {
        add(AuthUserChanged(state.session!.user));
        return;
      }
    });
    on<AuthUserChanged>((event, emit) {
      if (event.user == null) {
        emit(AuthState.unauthenticated());
        return;
      } else {
        emit(AuthState.authenticated(event.user!));
      }
      goRouter.refresh();
    });
    on<AuthLogoutRequested>((event, emit) async {
      await _authRepository.signOut();
      emit(AuthState.unauthenticated());
      goRouter.refresh();
    });
    on<DeleteAccount>((event, emit) async {
      await _authRepository.deleteAccount();
      emit(AuthState.unauthenticated());
      goRouter.refresh();
    });
    return;
  }
}
