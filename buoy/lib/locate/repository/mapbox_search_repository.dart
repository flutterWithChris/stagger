import 'package:buoy/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_search/mapbox_search.dart';

class MapboxSearchRepository {
  final GeoCoding _geoCoding =
      GeoCoding(apiKey: dotenv.get('MAPBOX_MAGNOLIA'), limit: 1);

  Future<({FailureResponse? failure, List<MapBoxPlace>? success})?>
      reverseGeocode(double lat, double lng) async {
    try {
      ({FailureResponse? failure, List<MapBoxPlace>? success}) places =
          await _geoCoding.getAddress((lat: lat, long: lng));

      print('Reverse Geocode: ${places.success!.first.placeName}');
      return places;
    } catch (e) {
      scaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(
          content: Text(
            'Error getting address from latlng: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
      print(e);
      return null;
    }
  }

  String getCityFromMapboxPlace(MapBoxPlace place) {
    String city = '';
    print('place: $place');
    for (var i = 0; i < place.geometry!.type.length; i++) {
      if (place.geometry!.type[i].contains('place')) {
        city = place.geometry!.type;
      }
    }
    return city;
  }

  String getStateFromMapboxPlace(MapBoxPlace place) {
    String state = '';
    // for (var i = 0; i < place!.length; i++) {
    //   if (place.context![i].id!.contains('region')) {
    //     state = place.context![i].text!;
    //   }
    // }
    return state;
  }
}
