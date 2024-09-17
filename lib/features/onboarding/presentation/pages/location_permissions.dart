import 'package:buoy/config/router/router.dart';
import 'package:buoy/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:buoy/features/onboarding/presentation/pages/onboarding.dart';
import 'package:buoy/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationPermissionsPage extends StatefulWidget {
  const LocationPermissionsPage({super.key});

  @override
  State<LocationPermissionsPage> createState() =>
      _LocationPermissionsPageState();
}

class _LocationPermissionsPageState extends State<LocationPermissionsPage> {
  bool _locationPermissionGranted = false;
  bool _locationAlwaysPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    context.read<OnboardingBloc>().add(SetCanMoveForwardCallback(
      () async {
        if (_locationPermissionGranted && _locationAlwaysPermissionGranted) {
          context.read<SubscriptionBloc>().add(ShowPaywall());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Please enable location permissions.')));
        }
      },
    ));
  }

  void _checkPermissions() async {
    var granted = await Permission.location.isGranted;
    var grantedAlways = await Permission.locationAlways.isGranted;
    setState(() {
      _locationPermissionGranted = granted;
      _locationAlwaysPermissionGranted = grantedAlways;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) async {
        if (state is SubscriptionError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is SubscriptionLoaded) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('onboardingComplete', true);
          context.go('/');
        }
      },
      child: Scaffold(
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
                    'First, we need permission to use your location.\n\nEnabling "always" is recommended, as it is needed to enable battery optimized location tracking.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w400)),
                const GutterLarge(),
                // Location Permissions ListTile
                ListTile(
                  onTap: () async => await Permission.location.request().then((value) => setState(() {
                    _locationPermissionGranted = value.isGranted;
                  }),),
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  tileColor: _locationPermissionGranted
                      ? Colors.green[400]
                      : Colors.redAccent,
                  title: const Text('Location Permissions'),
                  trailing: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8.0,
                    children: [
                      Icon(
                        _locationPermissionGranted
                            ? Icons.check_circle_rounded
                            : Icons.near_me_disabled_rounded,
                        size: 16.0,
                        color: Colors.white,
                      ),
                      Text(
                          _locationPermissionGranted ? 'Enabled' : 'Disabled',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ],
                  ),
                ),
                const Gutter(),
                // Background Location Permissions ListTile
           
                const Gutter(),
                Row(
                  children: [
                    Expanded(
                      child:
                       _locationPermissionGranted
                          ? FilledButton(
                              onPressed: () {
                                context
                                    .read<SubscriptionBloc>()
                                    .add(ShowPaywall());
                              },
                              child: const Text('Continue'),
                            )
                          :
                           FilledButton(
                              onPressed: () async {
                                await Permission.locationWhenInUse.request().then((permission) async {
                                  setState(() {
                                  _locationPermissionGranted = permission.isGranted;
                                });
                                });
                                await Permission.locationAlways.request().then((permission) async {
                                  setState(() {
                                  _locationAlwaysPermissionGranted = permission.isGranted;
                                });
                                });
                             
                               // _checkPermissions();
                              },
                              child:
                                  const Text('Enable Location Permissions'),
                            ),
                    ),
                  ],
                ),
                const Text(
                  '\n\nLocation data is never shared or sold to third-parties. You can also easily disable location updates at any time via the switch on the top app bar.',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
