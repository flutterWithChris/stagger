import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:buoy/core/constants.dart';
import 'package:buoy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:buoy/features/rides/model/ride.dart';
import 'package:buoy/features/rides/model/ride_participant.dart';
import 'package:buoy/features/rides/repository/ride_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart' as sb;
import 'package:supabase_flutter/supabase_flutter.dart';

part 'rides_event.dart';
part 'rides_state.dart';

class RidesBloc extends Bloc<RidesEvent, RidesState> {
  final RideRepository _rideRepository;
  StreamSubscription? ridesStreamSubscription;
  StreamSubscription? receivedRidesSubscription;
  StreamSubscription? ridesSubscription;

  RidesBloc({
    required RideRepository rideRepository,
    required AuthBloc authBloc,
  })  : _rideRepository = rideRepository,
        super(RidesInitial()) {
    on<LoadRides>(_onLoadRides);
    on<FetchRiders>(_onFetchRiders);
    on<LoadRidesWithinBounds>(_onLoadRidesWithinBounds,
        transformer: throttle(const Duration(seconds: 2)));
  }

  Future<void> _onLoadRides(LoadRides event, Emitter<RidesState> emit) async {
    try {
      emit(RidesLoading());

      // Stream My Rides
      await emit.forEach(_rideRepository.getRidesStream(), onData: (rides) {
        if (rides.isEmpty) {
          return const RidesLoaded([], []);
        }

        if (event.bounds != null) {
          rides = rides.where((ride) {
            if (ride.meetingPoint == null) return false;
            return event.bounds!.contains(LatLng(
              ride.meetingPoint![0],
              ride.meetingPoint![1],
            ));
          }).toList();
        }

        final myRides = rides
            .where((ride) =>
                ride.userId == sb.Supabase.instance.client.auth.currentUser!.id)
            .toList();
        final receivedRides = rides
            .where((ride) =>
                ride.userId != sb.Supabase.instance.client.auth.currentUser!.id)
            .toList();

        return RidesLoaded(myRides, receivedRides);
      });
    } catch (e) {
      emit(RidesError(e.toString()));
    }
  }

  Future<void> _onFetchRiders(
      FetchRiders event, Emitter<RidesState> emit) async {
    try {
      emit(RidesLoading());

      // Fetch participants for all rides
      List<Ride> myRides = event.myRides;
      List<Ride> receivedRides = event.receivedRides;
      List<Ride> myRidesWithParticipants = [];
      List<Ride> receivedRidesWithParticipants = [];
      for (Ride ride in myRides) {
        List<RideParticipant>? participants =
            await _rideRepository.getRideParticipants(ride.id!);
        if (participants == null) {
          emit(const RidesError('Error loading ride participants'));
          return;
        }
        myRidesWithParticipants
            .add(ride.copyWith(rideParticipants: participants));
      }
      // Fetch participants for received rides
      for (Ride ride in receivedRides) {
        List<RideParticipant>? participants =
            await _rideRepository.getRideParticipants(ride.id!);
        if (participants == null) {
          emit(const RidesError('Error loading ride participants'));
          return;
        }
        receivedRidesWithParticipants
            .add(ride.copyWith(rideParticipants: participants));
      }

      emit(RidesLoaded(myRidesWithParticipants, receivedRidesWithParticipants));
    } catch (e) {
      emit(RidesError(e.toString()));
    }
  }

  Future<void> _onLoadRidesWithinBounds(
      LoadRidesWithinBounds event, Emitter<RidesState> emit) async {
    try {
      List<Ride> myRides = [
        ...?state.myRides,
      ];
      List<Ride> receivedRides = [
        ...?state.receivedRides,
      ];
      emit(RidesLoading());

      // Fetch rides within bounds
      final ridesWithinBounds =
          await _rideRepository.fetchRidesWithinBounds(event.bounds);

      if (ridesWithinBounds.isEmpty) {
        emit(RidesLoaded(myRides, receivedRides));
        return;
      } else {
        receivedRides.addAll(ridesWithinBounds
            .where((ride) =>
                ride.userId != sb.Supabase.instance.client.auth.currentUser!.id)
            .toList());
        myRides.addAll(ridesWithinBounds
            .where((ride) =>
                ride.userId == sb.Supabase.instance.client.auth.currentUser!.id)
            .toList());

        emit(RidesLoaded(myRides, receivedRides));
      }
    } catch (e) {
      emit(RidesError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    ridesStreamSubscription?.cancel();
    receivedRidesSubscription?.cancel();

    return super.close();
  }
}
