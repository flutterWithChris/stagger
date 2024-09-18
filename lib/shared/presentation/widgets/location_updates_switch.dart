import 'dart:io';

import 'package:buoy/core/constants.dart';
import 'package:buoy/features/locate/bloc/geolocation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';

class LocationUpdatesSwitch extends StatelessWidget {
  const LocationUpdatesSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
        thumbIcon: WidgetStatePropertyAll(
          context.watch<GeolocationBloc>().state.locationUpdatesEnabled != false
              ? Icon(
                  Icons.location_on_rounded,
                  color: Platform.isIOS ? Colors.black87 : null,
                )
              : Icon(
                  Icons.location_off_rounded,
                  color: Platform.isIOS ? Colors.black87 : null,
                ),
        ),
        value: context.watch<GeolocationBloc>().state.locationUpdatesEnabled !=
            false,
        onChanged: (value) {
          if (context.read<GeolocationBloc>().state is GeolocationLoading) {
            return;
          }
          if (value == false) {
            context.read<GeolocationBloc>().add(StopGeoLocation());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.grey[800],
                content: const Row(
                  children: [
                    Icon(Icons.location_off_rounded,
                        color: Colors.white, size: 20),
                    GutterTiny(),
                    Text('Location updates disabled',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          } else {
            context.read<GeolocationBloc>().add(LoadGeolocation());
            ScaffoldMessenger.of(context).showSnackBar(
              getSuccessSnackbar(
                'Location updates enabled',
              ),
            );
          }
        });
  }
}
