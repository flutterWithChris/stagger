import 'package:bloc/bloc.dart';
import 'package:buoy/riders/model/rider.dart';
import 'package:buoy/riders/repo/riders_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_map/flutter_map.dart';

part 'riders_event.dart';
part 'riders_state.dart';

class RidersBloc extends Bloc<RidersEvent, RidersState> {
  final RidersRepository _ridersRepository;
  RidersBloc({
    required RidersRepository ridersRepository,
  })  : _ridersRepository = ridersRepository,
        super(RidersInitial()) {
    on<LoadRiders>((event, emit) async {
      try {
        print('LoadRiders');
        emit(RidersLoading());
        await _ridersRepository
            .fetchRidersWithinBounds(event.bounds)
            .then((riders) {
          print('riders: $riders');
          emit(RidersLoaded(riders));
        }).catchError((error) {
          print(error);
          emit(RidersError(error.toString()));
        });
      } catch (e) {
        print(e);
        emit(RidersError(e.toString()));
      }
    });
  }
}
