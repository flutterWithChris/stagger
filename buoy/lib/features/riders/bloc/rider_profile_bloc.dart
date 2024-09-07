import 'package:bloc/bloc.dart';
import 'package:buoy/features/riders/model/rider.dart';
import 'package:equatable/equatable.dart';

part 'rider_profile_event.dart';
part 'rider_profile_state.dart';

class RiderProfileBloc extends Bloc<RiderProfileEvent, RiderProfileState> {
  RiderProfileBloc() : super(RiderProfileInitial()) {
    on<LoadRiderProfile>((event, emit) {
      emit(RiderProfileLoading());
      try {
        final rider = event.rider;
        final riderId = event.riderId;
        if (rider != null) {
          emit(RiderProfileLoaded(rider));
        } else if (riderId != null) {
          emit(RiderProfileLoaded(Rider(id: riderId)));
        } else {
          emit(const RiderProfileError('No rider or riderId provided'));
        }
      } catch (e) {
        emit(RiderProfileError(e.toString()));
      }
    });
  }
}
