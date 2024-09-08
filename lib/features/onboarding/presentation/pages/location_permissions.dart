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

class LocationPermissionsPage extends StatefulWidget {
  const LocationPermissionsPage({super.key});

  @override
  State<LocationPermissionsPage> createState() =>
      _LocationPermissionsPageState();
}

class _LocationPermissionsPageState extends State<LocationPermissionsPage> {
  @override
  void initState() {
    // TODO: implement initState
    context.read<OnboardingBloc>().add(SetCanMoveForwardCallback(
      () async {
        var granted = await Permission.location.isGranted;
        var grantedAlways = await Permission.locationAlways.isGranted;
        if (granted && grantedAlways) {
          context.read<SubscriptionBloc>().add(ShowPaywall());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Please enable location permissions.')));
        }
      },
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is SubscriptionLoaded) {
          print('Subscription loaded');
          context.go('/');
          print('Attempting to navigate to /');
        }
        // TODO: implement listener
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
                FutureBuilder<bool?>(
                    future: Permission.location.isGranted,
                    builder: (context, snapshot) {
                      var granted = snapshot.data ?? false;
                      return ListTile(
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        tileColor:
                            granted ? Colors.green[400] : Colors.redAccent,
                        title: const Text('Location Permissions'),
                        trailing: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8.0,
                          children: [
                            Icon(
                              granted
                                  ? Icons.check_circle_rounded
                                  : Icons.near_me_disabled_rounded,
                              size: 16.0,
                              color: Colors.white,
                            ),
                            Text(granted ? 'Enabled' : 'Disabled',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
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
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        tileColor:
                            granted ? Colors.green[400] : Colors.redAccent,
                        title: const Text(
                          'Background Location',
                        ),
                        trailing: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8.0,
                          children: [
                            Icon(
                              granted
                                  ? Icons.check_circle_rounded
                                  : Icons.location_disabled_rounded,
                              size: 16.0,
                              color: Colors.white,
                            ),
                            Text(granted ? 'Enabled' : 'Disabled',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                          ],
                        ),
                      );
                    }),
                const Gutter(),
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder(
                          future: Future.wait([
                            Permission.location.isGranted,
                            Permission.locationAlways.isGranted,
                          ]),
                          builder: (context, snapshot) {
                            var granted = snapshot.data;
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return FilledButton(
                                  onPressed: () {},
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ));
                            }
                            if (granted != null && granted.contains(false)) {
                              return FilledButton(
                                onPressed: () async {
                                  await Permission.location.request();
                                  await Permission.locationAlways.request();
                                  setState(() {});
                                },
                                child:
                                    const Text('Enable Location Permissions'),
                              );
                            }
                            return const SizedBox();

                            BlocConsumer<SubscriptionBloc, SubscriptionState>(
                              listener: (context, state) {
                                if (state is SubscriptionError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(state.message)));
                                }
                              },
                              builder: (context, state) {
                                return FilledButton(
                                  onPressed: () async {
                                    context
                                        .read<SubscriptionBloc>()
                                        .add(ShowPaywall());
                                  },
                                  child: const Text('Continue'),
                                );
                              },
                            );
                          }),
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
