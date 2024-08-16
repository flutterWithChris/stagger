import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:buoy/locate/repository/mapbox_search_repository.dart';
import 'package:buoy/riders/bloc/riders_bloc.dart';
import 'package:buoy/rides/bloc/rides_bloc.dart';
import 'package:buoy/rides/model/ride.dart';
import 'package:buoy/rides/repository/ride_repository.dart';
import 'package:buoy/shared/constants.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'ride_event.dart';
part 'ride_state.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  final MapboxSearchRepository _mapboxSearchRepository;
  final RideRepository _rideRepository;
  final RidesBloc _ridesBloc;
  final RidersBloc _ridersBloc;
  StreamSubscription? rideParticipantsSubscription;
  RideBloc({
    required MapboxSearchRepository mapboxSearchRepository,
    required RideRepository rideRepository,
    required RidesBloc ridesBloc,
    required RidersBloc ridersBloc,
  })  : _mapboxSearchRepository = mapboxSearchRepository,
        _rideRepository = rideRepository,
        _ridesBloc = ridesBloc,
        _ridersBloc = ridersBloc,
        super(RideInitial()) {
    on<CreateRide>((event, emit) {
      emit(RideLoading());

      emit(CreatingRide(event.ride));
      print('Creating ride: ${event.ride}');
    });
    on<UpdateRideDraft>((event, emit) async {
      Ride ride = event.ride;
      if (event.ride.meetingPoint != null &&
          event.ride.meetingPointName == null) {
        var placeResult = await _mapboxSearchRepository.reverseGeocode(
          event.ride.meetingPoint![0],
          event.ride.meetingPoint![1],
        );
        if (placeResult!.failure != null) {
          emit(RideError(placeResult.failure!.message!));
          return;
        } else {
          MapBoxPlace place = placeResult.success!.first;
          ride = ride.copyWith(
            meetingPointName: place.placeName,
            meetingPointAddress: place.placeName,
          );
        }
      }
      print('Updating ride draft: $ride');
      emit(CreatingRide(ride));
    });
    on<SendRideRequest>((event, emit) async {
      try {
        emit(RideLoading());
        await _rideRepository.createRide(event.ride);
        print('Requesting ride: ${event.ride}');
        emit(RideRequestSent(event.ride));
      } catch (e) {
        print('Error requesting ride: $e');
        emit(RideError(e.toString(), ride: event.ride));
      }
    });
    on<UpdateArrivalStatus>((event, emit) async {
      try {
        emit(RideLoading());
        await _rideRepository.updateArrivalStatus(
            event.ride, event.userId, event.arrivalStatus);

        print('Updating ride: ${event.ride}');
        emit(RideUpdated(event.ride));

        scaffoldMessengerKey.currentState!.showSnackBar(
          const SnackBar(
            content: Text('Arrival status updated'),
          ),
        );
      } catch (e) {
        print('Error updating ride: $e');
        emit(RideError(e.toString(), ride: event.ride));
      }
    });
    on<JoinRide>((event, emit) async {
      try {
        emit(RideLoading());
        Ride? updatedRide = await _rideRepository.joinRide(
            event.ride, Supabase.instance.client.auth.currentUser!.id);
        if (updatedRide == null) {
          emit(const RideError('Error joining ride'));
          print('Error joining ride');
          return;
        }
        print('Joining ride: $updatedRide');
        emit(JoinedRide(updatedRide));
      } catch (e) {
        print('Error accepting ride: $e');
        emit(RideError(e.toString(), ride: event.ride));
      }
    });

    on<UpdateRide>((event, emit) async {
      try {
        emit(RideLoading());
        await _rideRepository.updateRide(event.ride);

        print('Updating ride: ${event.ride}');
        emit(RideUpdated(event.ride));
      } catch (e) {
        print('Error updating ride: $e');
        emit(RideError(e.toString(), ride: event.ride));
      }
    });
    on<FinishRide>((event, emit) async {
      try {
        emit(RideLoading());
        Ride? completedRide = await _rideRepository.finishRide(event.ride);
        if (completedRide == null) {
          emit(const RideError('Error finishing ride'));
          print('Error finishing ride');
          return;
        }
        print('Finishing ride: ${event.ride}');
        emit(RideCompleted(event.ride));
      } catch (e) {
        print('Error finishing ride: $e');
        emit(RideError(e.toString(), ride: event.ride));
      }
    });
    on<SelectRide>((event, emit) async {
      emit(RideLoading());
      print('Selected ride: ${event.ride}');
      emit(RideLoaded(event.ride));
    });
    on<LoadRideParticipants>((event, emit) async {
      try {
        emit(RideLoading());
        print('Loading ride participants: ${event.ride}');
        await emit
            .forEach(_rideRepository.getRideParticipantsStream(event.ride.id!),
                onData: (rideParticipants) {
          if (rideParticipants.isEmpty) {
            print('No ride participants found.');
            return RideLoaded(event.ride);
          }
          print(
              'Ride participants: ${rideParticipants.map((e) => e.toString())}');
          List<String> riderIds = rideParticipants.map((e) => e.id!).toList();
          _ridersBloc.add(LoadRiders(riderIds: riderIds));
          return RideLoaded(
              event.ride.copyWith(rideParticipants: rideParticipants));
        });
      } catch (e) {
        print('Error loading ride: $e');
        emit(RideError(e.toString()));
      }
    });
  }
  @override
  Future<void> close() {
    // TODO: implement close
    rideParticipantsSubscription?.cancel();
    return super.close();
  }
}
