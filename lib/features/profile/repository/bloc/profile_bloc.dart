import 'package:bloc/bloc.dart';
import 'package:buoy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:buoy/features/profile/repository/user_repository.dart';
import 'package:meta/meta.dart';

import '../../../../shared/models/user.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;
  final AuthBloc _authBloc;
  ProfileBloc({required UserRepository userRepository, required AuthBloc authBloc})
      : _userRepository = userRepository,
        _authBloc = authBloc,
        super(ProfileLoading()) {
    _authBloc.stream.listen((authState){
      if (authState.status == AuthStatus.authenticated && authState.user != null){
        add(LoadProfile(authState.user!.id));
      }
    });
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  void _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      print('Loading profile for user ${event.userId}');
      final user = await _userRepository.getUserById(event.userId);
      user == null
          ? emit(const ProfileError('User not found'))
          : emit(ProfileLoaded(user));
      print('Profile loaded: $user');
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
}
