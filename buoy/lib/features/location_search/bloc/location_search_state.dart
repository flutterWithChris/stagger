part of 'location_search_bloc.dart';

sealed class LocationSearchState extends Equatable {
  const LocationSearchState();
  
  @override
  List<Object> get props => [];
}

final class LocationSearchInitial extends LocationSearchState {}
