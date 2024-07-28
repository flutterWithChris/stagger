import 'package:bloc/bloc.dart';
import 'package:buoy/auth/repository/auth_repository.dart';
import 'package:buoy/core/router/router.dart';
import 'package:buoy/profile/repository/bloc/profile_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart' as supabase;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final ProfileBloc _profileBloc;
  AuthBloc(
      {required AuthRepository authRepository,
      required ProfileBloc profileBloc})
      : _authRepository = authRepository,
        _profileBloc = profileBloc,
        super(AuthState.initial()) {
    _authRepository.authStateChanges.listen((state) {
      print('Auth state changed');
      print('Session: ${state.session}');
      if (state.session != null) {
        print('Session is not null');
        add(AuthUserChanged(state.session!.user));
        return;
      }
    });
    on<AuthUserChanged>((event, emit) {
      print('User changed');
      if (event.user == null) {
        emit(AuthState.unauthenticated());
        return;
      } else {
        print('User is not null');
        emit(AuthState.authenticated(event.user!));
        _profileBloc.add(LoadProfile(event.user!.id));
      }
      goRouter.refresh();
    });
    on<AuthLogoutRequested>((event, emit) async {
      await _authRepository.signOut();
      emit(AuthState.unauthenticated());
      goRouter.refresh();
    });
    return;
  }
}
