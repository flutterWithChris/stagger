import 'package:bloc/bloc.dart';
import 'package:buoy/features/locate/repository/background_location_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

part 'motion_event.dart';
part 'motion_state.dart';

class MotionBloc extends Bloc<MotionEvent, MotionState> {
  final BackgroundLocationRepository _backgroundLocationRepository;
  MotionBloc(
      {required BackgroundLocationRepository backgroundLocationRepository})
      : _backgroundLocationRepository = backgroundLocationRepository,
        super(MotionInitial()) {
    on<LoadMotion>(_onLoadMotion);
    on<UpdateMotion>(_onUpdateMotion);
  }

  void _onLoadMotion(
    LoadMotion event,
    Emitter<MotionState> emit,
  ) async {
    emit(MotionLoading());
    _backgroundLocationRepository.onMotionChange((bg.Location location) {
      add(UpdateMotion(isMoving: location.isMoving));
      return;
    });
    emit(MotionLoaded(isMoving: event.isMoving));
  }

  void _onUpdateMotion(
    UpdateMotion event,
    Emitter<MotionState> emit,
  ) async {
    emit(MotionLoading());
    emit(MotionLoaded(isMoving: event.isMoving));
    _backgroundLocationRepository.onMotionChange((bg.Location location) {
      add(UpdateMotion(isMoving: location.isMoving));
    });
  }
}
