import 'package:bloc/bloc.dart';
import 'package:buoy/features/locate/repository/background_location_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

part 'activity_event.dart';
part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final BackgroundLocationRepository _backgroundLocationRepository;
  ActivityBloc(
      {required BackgroundLocationRepository backgroundLocationRepository})
      : _backgroundLocationRepository = backgroundLocationRepository,
        super(ActivityInitial()) {
    on<LoadActivity>(_onLoadActivity);
    on<UpdateActivity>(_onUpdateActivity);
  }

  void _onLoadActivity(
    LoadActivity event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    emit(ActivityLoaded(activity: event.activity));
    _backgroundLocationRepository
        .onActivityChange((bg.ActivityChangeEvent event) {
      print('[activitychange] - $event');
      add(UpdateActivity(activity: event.activity));
    });
  }

  void _onUpdateActivity(
    UpdateActivity event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    emit(ActivityLoaded(activity: event.activity));
    _backgroundLocationRepository
        .onActivityChange((bg.ActivityChangeEvent event) {
      print('[activitychange] - $event');
      add(UpdateActivity(activity: event.activity));
    });
  }
}
