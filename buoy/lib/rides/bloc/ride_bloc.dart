import 'package:bloc/bloc.dart';
import 'package:buoy/locate/repository/mapbox_search_repository.dart';
import 'package:buoy/rides/model/ride.dart';
import 'package:buoy/rides/repository/ride_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:mapbox_search/mapbox_search.dart';

part 'ride_event.dart';
part 'ride_state.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  final MapboxSearchRepository _mapboxSearchRepository;
  final RideRepository _rideRepository;
  RideBloc({
    required MapboxSearchRepository mapboxSearchRepository,
    required RideRepository rideRepository,
  })  : _mapboxSearchRepository = mapboxSearchRepository,
        _rideRepository = rideRepository,
        super(RideInitial()) {
    on<CreateRide>((event, emit) {
      emit(RideLoading());

      emit(CreatingRide(event.ride));
      print('Creating ride: ${event.ride}');
    });
    on<UpdateRideDraft>((event, emit) async {
      Ride ride = event.ride;
      if (event.ride.meetingPoint != null) {
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
  }
}
