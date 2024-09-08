import 'package:bloc/bloc.dart';
import 'package:buoy/features/profile/repository/user_repository.dart';
import 'package:buoy/features/riders/model/rider.dart';
import 'package:buoy/features/riders/repo/riders_repository.dart';
import 'package:buoy/shared/models/user.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart' as sb;

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final UserRepository _userRepository;
  final RidersRepository _ridersRepository;
  bool canMoveForward = false;
  Function()? checkCanMoveForward;
  final PageController pageController = PageController();
  OnboardingBloc(
      {required UserRepository userRepository,
      required RidersRepository ridersRepository})
      : _userRepository = userRepository,
        _ridersRepository = ridersRepository,
        super(OnboardingInitial()) {
    on<StartOnboarding>((event, emit) async {
      emit(OnboardingLoading());
      try {
        print('Starting onboarding with user: ${event.user}');
        final response = await _userRepository.createUser(
            user: User(
          id: event.user.id,
          email: event.user.email!,
        ));
        response.fold((l) {
          print(l.message);
          emit(OnboardingError(message: l.message));
        }, (user) {
          add(CreateRider(user: user));
        });
      } catch (e) {
        print(e);
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
        print('Rider created');
        emit(OnboardingLoaded(
            isOnboardingComplete: true, user: event.user, rider: rider));
      } catch (e) {
        print(e);
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
          emit(RiderUpdated(rider: rider));
          emit(OnboardingLoaded(
              isOnboardingComplete: true, user: event.user, rider: rider));
        });
      } catch (e) {
        emit(OnboardingError(message: e.toString()));
      }
    });
    on<SetCanMoveForward>((event, emit) async {
      canMoveForward = event.canMoveForward;
    });
    on<SetCanMoveForwardCallback>((event, emit) async {
      checkCanMoveForward = event.callback;
    });
    on<MoveForward>((event, emit) async {
      pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }
}
