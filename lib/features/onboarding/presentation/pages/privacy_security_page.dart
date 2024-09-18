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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Image.asset(
                    'lib/assets/screenshots/main_map_dark.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gutter(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                              Text('Create Rides',
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
                      Flexible(
                        child: 
                        Text.rich(
                          TextSpan(
                            text: 'Use the',
                            children: [
                              WidgetSpan(child:     Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                height: 24.0,
                                child: FittedBox(
                                  child: FloatingActionButton(
                                    onPressed: () {},
                                    child: const Icon(Icons.add_rounded),
                                  ),
                                ),
                                                            ),
                              ),),
    const TextSpan(text: 'button on the map to create a ride.',
                           ),
                            const TextSpan(
                               text: 'You can set meeting points, times, & set ride privacy.',
                                ),
                            ]),
                        ),
                      ),
                      const GutterLarge(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
