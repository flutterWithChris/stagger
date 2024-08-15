import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'location_search_event.dart';
part 'location_search_state.dart';

class LocationSearchBloc extends Bloc<LocationSearchEvent, LocationSearchState> {
  LocationSearchBloc() : super(LocationSearchInitial()) {
    on<LocationSearchEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
