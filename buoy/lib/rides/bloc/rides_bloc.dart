import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:buoy/auth/bloc/auth_bloc.dart';
import 'package:buoy/rides/model/ride.dart';
import 'package:buoy/rides/model/ride_participant.dart';
import 'package:buoy/rides/repository/ride_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart' as sb;
import 'package:supabase_flutter/supabase_flutter.dart';

part 'rides_event.dart';
part 'rides_state.dart';

class RidesBloc extends Bloc<RidesEvent, RidesState> {
  final RideRepository _rideRepository;
  final AuthBloc _authBloc;
  StreamSubscription? ridesStreamSubscription;
  StreamSubscription? receivedRidesSubscription;

  RidesBloc({
    required RideRepository rideRepository,
    required AuthBloc authBloc,
  })  : _rideRepository = rideRepository,
        _authBloc = authBloc,
        super(RidesInitial()) {
    _authBloc.stream.listen((authState) {
      if (authState.status == AuthStatus.authenticated) {
        print('Authenticated');
        _subscribeToAllRides();
      }
    });

    on<LoadRides>(_onLoadRides);
    on<FetchRiders>(_onFetchRiders);
  }

  void _subscribeToAllRides() {
    ridesStreamSubscription = _rideRepository
        .getMyParticipantsStream(
      sb.Supabase.instance.client.auth.currentUser!.id,
    )
        .listen((myParticipants) {
      print('Rides stream event: $myParticipants');

      // Collect all ride IDs
      final allRideIds = myParticipants.map((p) => p['ride_id']).toSet();

      // Subscribe to each ride's participants
      for (var rideId in allRideIds) {
        _rideRepository
            .getRideParticipantsStream(rideId)
            .listen((participants) {
          print('Participants stream update for ride $rideId: $participants');

          // You can now dispatch LoadRides or a similar event to process these participants
          final rideParticipants = participants.map((p) => p).toList();
          add(LoadRides(rideParticipants));
        });
      }
    });
  }

  Future<void> _onLoadRides(LoadRides event, Emitter<RidesState> emit) async {
    try {
      emit(RidesLoading());

      print('Rides stream event: $event');
      List<Ride> myRides = [];
      List<Ride> receivedRides = [];
      List<String> rideIds = [];

      for (RideParticipant rideParticipant in event.rideParticipants) {
        if (!rideIds.contains(rideParticipant.rideId)) {
          rideIds.add(rideParticipant.rideId!);
        }
      }

      List<Stream<Ride?>> rideStreams = rideIds.map((rideId) {
        print('Fetching ride: $rideId');
        return _rideRepository.getRideStream(rideId);
      }).toList();

      List<Stream<List<RideParticipant>>> participantStreams =
          rideIds.map((rideId) {
        return _rideRepository.getRideParticipantsStream(rideId);
      }).toList();

      // Combine both ride and participant streams
      Stream<List<Ride>> combinedRidesStream = Rx.combineLatest2(
        Rx.combineLatest(rideStreams, (rides) {
          return rides.whereType<Ride>().toList(); // Filter out null rides
        }),
        Rx.combineLatest(participantStreams, (participantLists) {
          return participantLists.cast<List<RideParticipant>>();
        }),
        (rides, participants) {
          // Match rides with their corresponding participants
          for (int i = 0; i < rides.length; i++) {
            rides[i] = rides[i].copyWith(rideParticipants: participants[i]);
          }
          return rides;
        },
      );

      await emit.forEach(
        combinedRidesStream,
        onData: (allRidesWithParticipants) {
          // Create a map of rides by ID to easily update existing ones
          final Map<String, Ride> rideMap = {};

          for (var ride in allRidesWithParticipants) {
            rideMap[ride.id!] = ride; // Use ride ID as key
          }

          // Convert map back to a list to maintain order
          final updatedRides = rideMap.values.toList();

          // Separate my rides and received rides based on the user ID
          final myRides = updatedRides
              .where((ride) =>
                  ride.userId ==
                  sb.Supabase.instance.client.auth.currentUser!.id)
              .toList();
          final receivedRides = updatedRides
              .where((ride) =>
                  ride.userId !=
                  sb.Supabase.instance.client.auth.currentUser!.id)
              .toList();

          return RidesLoaded(myRides, receivedRides);
        },
        onError: (error, stackTrace) {
          print('Error loading rides: $error');
          return RidesError(error.toString());
        },
      );
    } catch (e) {
      print('Error loading rides: $e');
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
        print('Ride ID: ${ride.id}');
        List<RideParticipant>? participants =
            await _rideRepository.getRideParticipants(ride.id!);
        if (participants == null) {
          emit(const RidesError('Error loading ride participants'));
          return;
        }
        myRidesWithParticipants
            .add(ride.copyWith(rideParticipants: participants));
      } // Fetch participants for received rides
      for (Ride ride in receivedRides) {
        List<RideParticipant>? participants =
            await _rideRepository.getRideParticipants(ride.id!);
        print('Participants: $participants');
        if (participants == null) {
          emit(const RidesError('Error loading ride participants'));
          return;
        }
        receivedRidesWithParticipants
            .add(ride.copyWith(rideParticipants: participants));
      }

      print('My rides with participants: $myRidesWithParticipants');
      print('Received rides with participants: $receivedRidesWithParticipants');

      emit(RidesLoaded(myRidesWithParticipants, receivedRidesWithParticipants));
    } catch (e) {
      print('Error loading ride participants: $e');
      emit(RidesError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    ridesStreamSubscription?.cancel();
    return super.close();
  }
}
