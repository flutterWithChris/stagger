import 'package:bloc/bloc.dart';
import 'package:buoy/rides/model/ride.dart';
import 'package:buoy/rides/repository/ride_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart' as sb;
part 'rides_event.dart';
part 'rides_state.dart';

class RidesBloc extends Bloc<RidesEvent, RidesState> {
  final RideRepository _rideRepository;
  RidesBloc({
    required RideRepository rideRepository,
  })  : _rideRepository = rideRepository,
        super(RidesInitial()) {
    on<LoadRides>((event, emit) async {
      try {
        emit(RidesLoading());

        final ridesStream = _rideRepository
            .getReceivedRides(sb.Supabase.instance.client.auth.currentUser!.id);

        await emit.forEach(
          ridesStream,
          onData: (rides) {
            print('Rides receieved: $rides');
            return RidesLoaded(rides.$1, rides.$2);
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
  }
}
