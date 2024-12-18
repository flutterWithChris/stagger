import 'package:bloc/bloc.dart';
import 'package:buoy/core/constants.dart';
import 'package:buoy/features/riders/model/rider.dart';
import 'package:buoy/features/riders/repo/riders_repository.dart';
import 'package:buoy/features/rides/bloc/ride_bloc.dart';
import 'package:buoy/features/rides/model/ride.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

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
        emit(RidersLoading());
        await _ridersRepository.fetchRidersWithinBounds(event.bounds).then(
          (riders) async {
            List<Rider> ridersWithoutUser = riders
                .where((rider) =>
                    rider.id != Supabase.instance.client.auth.currentUser?.id)
                .toList();

            // emit(RidersLoaded(ridersWithoutUser));
            await emit.forEach(
              _ridersRepository.streamRiderLocations(ridersWithoutUser),
              onData: (riders) {
                return RidersLoaded(riders);
              },
              onError: (error, stackTrace) =>
                  const RidersError('Error fetching riders in view.'),
            );
          },
        ).catchError((error) {
          print(error);
          emit(RidersError(error.toString()));
        });
      } catch (e) {
        print(e);
        emit(RidersError(e.toString()));
      }
    }, transformer: throttle(const Duration(seconds: 2)));
    on<LoadRiders>(
      (event, emit) async {
        try {
          List<Rider> oldStateRiders = state.riders ?? [];

          emit(RidersLoading());

          await _ridersRepository.fetchRiders(event.riderIds).then((riders) {
            emit(RidersLoaded(riders));
          }).catchError((error) {
            print(error);
            emit(RidersError(error.toString()));
          });
        } catch (e) {
          print(e);
          emit(RidersError(e.toString()));
        }
      },
    );
    on<UpdateRider>((event, emit) async {
      try {
        List<Rider>? oldStateRiders = state.riders;
        final response = await _ridersRepository.updateRider(event.rider);
        response.fold((failure) {
          emit(const RidersError('Error updating Rider!'));
        }, (rider) {
          oldStateRiders?.removeWhere((rider) => rider.id == rider.id);
          List<Rider> updateRiderList = [
            ...?oldStateRiders,
            rider,
          ];
          emit(RidersLoaded(updateRiderList));
        });
      } catch (e) {
        print(e);
        emit(const RidersError('Error updating Rider'));
      }
    });
  }
}
