import 'package:buoy/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_search/mapbox_search.dart';

class MapboxSearchRepository {
  final ReverseGeoCoding _reverseGeoCoding =
      ReverseGeoCoding(apiKey: dotenv.get('MAPBOX_MAGNOLIA'), limit: 1);

  Future<List<MapBoxPlace>?> reverseGeocode(double lat, double lng) async {
    try {
      List<MapBoxPlace>? places =
          await _reverseGeoCoding.getAddress(Location(lat: lat, lng: lng));
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
    for (var i = 0; i < place.context!.length; i++) {
      if (place.context![i].id!.contains('place')) {
        city = place.context![i].text!;
      }
    }
    return city;
  }

  String getStateFromMapboxPlace(MapBoxPlace place) {
    String state = '';
    for (var i = 0; i < place.context!.length; i++) {
      if (place.context![i].id!.contains('region')) {
        state = place.context![i].text!;
      }
    }
    return state;
  }
}
