import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionsPage extends StatelessWidget {
  const LocationPermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(36.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8.0,
                children: [
                  const Icon(Icons.location_pin, size: 24.0),
                  Text('Location Permissions',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          fontFamily: GoogleFonts.corben().fontFamily)),
                ],
              ),
              const Gutter(),
              Text(
                  'First, we need permission to use your location.\n\nChoose "Always" to ensure your location is updated in the background.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w400)),
              const GutterLarge(),
              FutureBuilder<bool?>(
                  future: Permission.location.isGranted,
                  builder: (context, snapshot) {
                    var granted = snapshot.data ?? false;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      tileColor: granted
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.redAccent,
                      title: const Text('Location Permissions'),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8.0,
                        children: [
                          Icon(
                            granted
                                ? Icons.check_rounded
                                : Icons.near_me_disabled_rounded,
                            size: 16.0,
                          ),
                          Text(granted ? 'Enabled' : 'Disabled',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }),
              const Gutter(),
              FutureBuilder<bool?>(
                  future: Permission.locationAlways.isGranted,
                  builder: (context, snapshot) {
                    var granted = snapshot.data ?? false;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      tileColor: granted
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.redAccent,
                      title: const Text('Background Location'),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8.0,
                        children: [
                          Icon(
                            granted
                                ? Icons.check_rounded
                                : Icons.location_disabled_rounded,
                            size: 16.0,
                          ),
                          Text(granted ? 'Enabled' : 'Disabled',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
