import 'package:buoy/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  @override
  void initState() {
    // TODO: implement initState
    context.read<OnboardingBloc>().add(const SetCanMoveForward(true));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    'lib/assets/screenshots/rider_details.png',
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
                            Text('Find Riding Buddies',
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
                            Icon(
                              PhosphorIcons.mapTrifold(),
                              // color: Theme.of(context).scaffoldBackgroundColor,
                              size: 20.0,
                            ),
                            Text(
                              'Live map with nearby riders!',
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
                            Icon(
                              PhosphorIcons.motorcycle(),
                              size: 20.0,
                            ),
                            Text('See bike type, riding style, & more',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w400)),
                          ],
                        ),
                        const GutterSmall(),
                        Wrap(
                          spacing: 8.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 20.0,
                            ),
                            Text('Add friends for future rides',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w400)),
                          ],
                        ),
                        const GutterLarge(),
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
