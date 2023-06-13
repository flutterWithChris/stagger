import 'package:bloc/bloc.dart';
import 'package:buoy/auth/repository/auth_repository.dart';
import 'package:buoy/core/router/router.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart' as supabase;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthState.initial()) {
    _authRepository.getAuthStateStream().listen((state) {
      add(AuthUserChanged(state.session!.user));
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
  }
}
