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
        ridesStreamSubscription = _rideRepository
            .getRideParticipantsStream(
          sb.Supabase.instance.client.auth.currentUser!.id,
        )
            .listen((event) {
          print('Rides stream event: $event');
          List<RideParticipant> rideParticipants = [];
          for (var record in event) {
            RideParticipant rideParticipant = RideParticipant.fromMap(record);
            rideParticipants.add(rideParticipant);
          }
          add(LoadRides(rideParticipants));
        });
      }
    });

    // on<LoadRides>((event, emit) async {
    //   try {
    //     emit(RidesLoading());

    //     print('Rides stream event: $event');
    //     List<Ride> myRides = [];
    //     List<Ride> receivedRides = [];
    //     List<String> rideIds = [];
    //     for (RideParticipant rideParticipant in event.rideParticipants) {
    //       if (rideIds.contains(rideParticipant.rideId)) {
    //         continue;
    //       } else {
    //         rideIds.add(rideParticipant.rideId!);
    //       }
    //     }
    //     for (String rideId in rideIds) {
    //       print('Fetching ride: $rideId');
    //       Ride? ride = await _rideRepository.getRide(rideId);
    //       print('Fetched ride: $ride');
    //       if (ride == null) {
    //         emit(const RidesError('Error loading rides'));
    //         return;
    //       }
    //       if (ride.userId == sb.Supabase.instance.client.auth.currentUser!.id) {
    //         myRides.add(ride);
    //       } else {
    //         receivedRides.add(ride);
    //       }
    //     }
    //     List<Ride> myRidesWithParticipants = [];
    //     List<Ride> receivedRidesWithParticipants = [];
    //     for (Ride ride in myRides) {
    //       List<RideParticipant>? participants =
    //           await _rideRepository.getRideParticipants(ride.id!);
    //       if (participants == null) {
    //         emit(const RidesError('Error loading ride participants'));
    //         return;
    //       }
    //       myRidesWithParticipants
    //           .add(ride.copyWith(rideParticipants: participants));
    //     } // Fetch participants for received rides
    //     for (Ride ride in receivedRides) {
    //       List<RideParticipant>? participants =
    //           await _rideRepository.getRideParticipants(ride.id!);
    //       print('Participants: $participants');
    //       if (participants == null) {
    //         emit(const RidesError('Error loading ride participants'));
    //         return;
    //       }
    //       receivedRidesWithParticipants
    //           .add(ride.copyWith(rideParticipants: participants));
    //     }
    //     emit(RidesLoaded(
    //         myRidesWithParticipants, receivedRidesWithParticipants));
    //   } catch (e) {
    //     print('Error loading rides: $e');
    //     emit(RidesError(e.toString()));
    //   }
    // });
    on<LoadRides>((event, emit) async {
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

        Stream<List<Ride>> combinedRidesStream =
            Rx.combineLatest(rideStreams, (rides) {
          print('Rides: $rides');
          for (var ride in rides) {
            print('Ride: $ride');
            if (ride == null) {
              emit(const RidesError('Error loading rides'));
              return [];
            }
            if (ride.userId ==
                sb.Supabase.instance.client.auth.currentUser!.id) {
              myRides.add(ride);
            } else {
              receivedRides.add(ride);
            }
          }
          return myRides + receivedRides;
        });

        // Asynchronous operation outside the stream
        combinedRidesStream = combinedRidesStream.asyncMap((allRides) async {
          List<RideParticipant> participants = [];
          List<Ride> allRidesWithParticipants = [];

          for (Ride ride in allRides) {
            participants =
                await _rideRepository.getRideParticipants(ride.id!) ?? [];
            if (participants.isEmpty) {
              emit(const RidesError('Error loading ride participants'));
              return [];
            }
            allRidesWithParticipants
                .add(ride.copyWith(rideParticipants: participants));
          }

          return allRidesWithParticipants;
        });

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
    });

    on<FetchRiders>((event, emit) async {
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
        print(
            'Received rides with participants: $receivedRidesWithParticipants');

        emit(RidesLoaded(
            myRidesWithParticipants, receivedRidesWithParticipants));
      } catch (e) {
        print('Error loading ride participants: $e');
        emit(RidesError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    // TODO: implement close
    ridesStreamSubscription?.cancel();
    return super.close();
  }
}
