import 'package:buoy/features/locate/bloc/geolocation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationUpdatesSwitch extends StatelessWidget {
  const LocationUpdatesSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
        thumbIcon: WidgetStatePropertyAll(
          context.watch<GeolocationBloc>().state.locationUpdatesEnabled != false
              ? const Icon(
                  Icons.location_on_rounded,
                )
              : const Icon(Icons.location_off_rounded),
        ),
        value: context.watch<GeolocationBloc>().state.locationUpdatesEnabled !=
            false,
        onChanged: (value) {
          if (value == false) {
            context.read<GeolocationBloc>().add(StopGeoLocation());
          } else {
            context.read<GeolocationBloc>().add(LoadGeolocation());
          }
        });
  }
}