import 'package:bloc/bloc.dart';
import 'package:buoy/features/auth/data/repository/auth_repository_impl.dart';
import 'package:buoy/features/auth/domain/repositories/auth_repository.dart';
import 'package:buoy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:buoy/features/profile/repository/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/models/user.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;
  final AuthRepositoryImpl _authRepository;
  final AuthBloc _authBloc;
  ProfileBloc(
      {required UserRepository userRepository,
      required AuthBloc authBloc,
      required AuthRepositoryImpl authRepository})
      : _userRepository = userRepository,
        _authBloc = authBloc,
        _authRepository = authRepository,
        super(ProfileLoading()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<DeleteProfile>(_onDeleteProfile);
  }

  void _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = await _userRepository.getUserById(event.userId);
      user == null
          ? emit(const ProfileError('User not found'))
          : emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  void _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await _userRepository.updateUser(event.user);
      emit(ProfileLoaded(event.user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  void _onDeleteProfile(DeleteProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await _userRepository.deleteUser(event.userId);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _authBloc.add(AuthLogoutRequested());
      emit(ProfileDeleted());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
