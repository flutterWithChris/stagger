import 'package:bloc/bloc.dart';
import 'package:buoy/features/profile/repository/user_repository.dart';
import 'package:buoy/features/riders/model/rider.dart';
import 'package:buoy/features/riders/repo/riders_repository.dart';
import 'package:buoy/shared/models/user.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase/supabase.dart' as sb;

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final UserRepository _userRepository;
  final RidersRepository _ridersRepository;
  OnboardingBloc(
      {required UserRepository userRepository,
      required RidersRepository ridersRepository})
      : _userRepository = userRepository,
        _ridersRepository = ridersRepository,
        super(OnboardingInitial()) {
    on<StartOnboarding>((event, emit) async {
      emit(OnboardingLoading());
      try {
        final response = await _userRepository.createUser(
          id: event.user.id,
          email: event.user.email!,
        );
        response.fold((l) => emit(OnboardingError(message: l.message)), (user) {
          add(CreateRider(user: user));
        });
      } catch (e) {
        emit(OnboardingError(message: e.toString()));
      }
    });
    on<CreateRider>((event, emit) async {
      emit(OnboardingLoading());
      try {
        Rider rider = Rider(id: event.user.id, email: event.user.email);
        await _ridersRepository.createRider(
          rider,
        );
        emit(OnboardingLoaded(
            isOnboardingComplete: true, user: event.user, rider: rider));
      } catch (e) {
        emit(OnboardingError(message: e.toString()));
      }
    });
    on<UpdateRider>((event, emit) async {
      emit(OnboardingLoading());
      try {
        final response = await _ridersRepository.updateRider(
          event.rider,
        );
        response.fold((l) => emit(OnboardingError(message: l.message)),
            (rider) {
          emit(OnboardingLoaded(
              isOnboardingComplete: true, user: event.user, rider: rider));
        });
      } catch (e) {
        emit(OnboardingError(message: e.toString()));
      }
    });
  }
}
