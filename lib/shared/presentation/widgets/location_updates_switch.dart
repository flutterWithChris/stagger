import 'dart:io';

import 'package:buoy/config/router/router.dart';
import 'package:buoy/core/constants.dart';
import 'package:buoy/features/locate/bloc/geolocation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationUpdatesSwitch extends StatelessWidget {
  const LocationUpdatesSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
        thumbIcon: WidgetStatePropertyAll(
          context.watch<GeolocationBloc>().locationUpdatesEnabled != false
              ? Icon(
                  Icons.location_on_rounded,
                  color: Platform.isIOS ? Colors.black87 : null,
                )
              : Icon(
                  Icons.location_off_rounded,
                  color: Platform.isIOS ? Colors.black87 : null,
                ),
        ),
        value: context.watch<GeolocationBloc>().locationUpdatesEnabled != false,
        onChanged: (value) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('locationUpdatesEnabled', value);
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
            // Check location permissions
            var granted = await Permission.location.isGranted;
            if (!granted) {
              // show dialog
              if (context.mounted) {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Location permissions disabled!'),
                      content: const Text(
                          'To enable location updates, please enable location permissions in app settings.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await openAppSettings();
                          },
                          child: const Text('Enable'),
                        ),
                      ],
                    );
                  },
                );
              }
              return;
            }
            // Show confirmation dialog
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Enable location updates?'),
                  content: const Text(
                      'This will allow others to see your location (delayed by 2 minutes).'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        context.pop();
                        context.read<GeolocationBloc>().add(LoadGeolocation());
                        ScaffoldMessenger.of(context).showSnackBar(
                          getSuccessSnackbar(
                            'Location updates enabled',
                          ),
                        );
                      },
                      child: const Text('Enable'),
                    ),
                  ],
                );
              },
            );
          }
        });
  }
}
