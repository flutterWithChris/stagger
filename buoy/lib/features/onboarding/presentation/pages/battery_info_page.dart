import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:google_fonts/google_fonts.dart';

class BatteryInfoPage extends StatelessWidget {
  const BatteryInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    'lib/assets/screenshots/ride_details.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Wrap(
                          spacing: 16.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Icon(
                            //   Icons.battery_full_rounded,
                            //   size: 20.0,
                            //   color: Colors.orange[800],
                            // ),
                            Text('Create & Organize Rides',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontFamily:
                                            GoogleFonts.corben().fontFamily)),
                          ],
                        ),
                      ],
                    ),
                    const Gutter(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Wrap(
                          spacing: 12.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(
                              Icons.mode_of_travel_rounded,
                              // color: Theme.of(context).scaffoldBackgroundColor,
                              size: 20.0,
                            ),
                            Text(
                              'Set meeting point & time',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            )
                          ],
                        ),
                        const GutterSmall(),
                        Wrap(
                          spacing: 8.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(
                              Icons.share_location_rounded,
                              size: 20.0,
                            ),
                            Text('See rider arrival status',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w400)),
                          ],
                        ),
                        Wrap(
                          spacing: 8.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(
                              Icons.remove_red_eye_rounded,
                              size: 20.0,
                            ),
                            Text('Set ride privacy',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w400)),
                            Chip(
                              label: const Text('Pro'),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer,
                              padding: EdgeInsets.zero,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            )
                          ],
                        ),
                        const GutterSmall(),

                        // FilledButton.icon(
                        //     style: FilledButton.styleFrom(
                        //       fixedSize: const Size(400, 40),
                        //     ),
                        //     onPressed: () async {
                        //       SharedPreferences prefs =
                        //           await SharedPreferences.getInstance();
                        //       prefs.setBool('onboardingComplete', true);
                        //       goRouter.go('/');
                        //     },
                        //     icon: const Icon(Icons.check_circle_outline_rounded),
                        //     label: const Text('Finish Setup'))
                      ],
                    ),
                    const GutterLarge(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
