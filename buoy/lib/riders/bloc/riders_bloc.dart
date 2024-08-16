import 'package:bloc/bloc.dart';
import 'package:buoy/riders/model/rider.dart';
import 'package:buoy/riders/repo/riders_repository.dart';
import 'package:buoy/rides/model/ride.dart';
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
    on<LoadRidersWithinBounds>((event, emit) async {
      try {
        print('Load Riders Within Bounds');
        emit(RidersLoading());
        await _ridersRepository
            .fetchRidersWithinBounds(event.bounds)
            .then((riders) {
          print('riders: ${riders.map((rider) => rider.toString())}');
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
    on<LoadRiders>((event, emit) async {
      try {
        List<Rider> oldStateRiders = state.riders ?? [];
        print('LoadRiders');
        print('Rider IDs: ${event.riderIds}');
        List<String> missingRiderIds = [];
        missingRiderIds = event.riderIds.where((riderId) {
          return oldStateRiders.every((rider) => rider.id != riderId);
        }).toList();
        emit(RidersLoading());
        if (missingRiderIds.isNotEmpty) {
          print('Missing Rider IDs: $missingRiderIds');
          await _ridersRepository.fetchRiders(missingRiderIds).then((riders) {
            print('riders: ${riders.map((rider) => rider.toString())}');
            emit(RidersLoaded([...oldStateRiders..addAll(riders)]));
          }).catchError((error) {
            print(error);
            emit(RidersError(error.toString()));
          });
        } else {
          emit(const RidersError('No riders to load'));
        }
      } catch (e) {
        print(e);
        emit(RidersError(e.toString()));
      }
    });
  }
}
