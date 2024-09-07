import 'package:buoy/core/constants.dart';
import 'package:buoy/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:buoy/features/riders/model/rider.dart';
import 'package:buoy/shared/buoy_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class GearPreferencePage extends StatefulWidget {
  const GearPreferencePage({super.key});

  @override
  State<GearPreferencePage> createState() => _GearPreferencePageState();
}

class _GearPreferencePageState extends State<GearPreferencePage> {
  GearLevel? _selectedGearLevel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('What gear do you wear?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.corben().fontFamily)),
                  ),
                  const GutterSmall(),
                  const Text(
                    '(be honest...)',
                  ),
                  const Gutter(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        // color: Colors.white,
                        borderRadius: BorderRadius.circular(36.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              onTap: () {
                                setState(() {
                                  _selectedGearLevel = GearLevel.none;
                                });
                              },
                              selected: _selectedGearLevel == GearLevel.none,
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: _selectedGearLevel == GearLevel.none
                                  ? RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 2.0))
                                  : null,
                              leading: Icon(PhosphorIcons.skull()),
                              title: const Text('No Gear. No Fear.'),
                              subtitle: const Text(
                                  'I just need a pair of shades & I\'m ready to roll.'),
                            ),
                            const Divider(),
                            ListTile(
                              onTap: () {
                                setState(() {
                                  _selectedGearLevel = GearLevel.some;
                                });
                              },
                              selected: _selectedGearLevel == GearLevel.some,
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: _selectedGearLevel == GearLevel.some
                                  ? RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 2.0))
                                  : null,
                              leading: Image.asset(
                                'lib/assets/icons/helmet_icon.png',
                                height: 20.0,
                                width: 20.0,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              title: const Text('The Basics'),
                              subtitle: const Text(
                                  'I wear a helmet, jacket or back protector & gloves; That\'s about it.'),
                            ),
                            const Divider(),
                            ListTile(
                              onTap: () {
                                setState(() {
                                  _selectedGearLevel = GearLevel.atgatt;
                                });
                              },
                              selected: _selectedGearLevel == GearLevel.atgatt,
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: _selectedGearLevel == GearLevel.atgatt
                                  ? RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 2.0))
                                  : null,
                              leading: Icon(PhosphorIcons.sealWarning(
                                  PhosphorIconsStyle.fill)),
                              title: const Text('ATGATT'),
                              subtitle: const Text(
                                  'All The Gear, All The Time. I\'m not taking any chances.'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: BlocBuilder<OnboardingBloc, OnboardingState>(
                        builder: (context, state) {
                          if (state is OnboardingLoading) {
                            return const CircularProgressIndicator();
                          }
                          if (state is OnboardingError) {
                            return Text(state.message);
                          }
                          if (state is OnboardingLoaded) {
                            return FilledButton(
                                onPressed: () {
                                  context.read<OnboardingBloc>().add(
                                      UpdateRider(
                                          rider: state.rider.copyWith(
                                              gearLevel: _selectedGearLevel),
                                          user: state.user));
                                },
                                child: const Text('Continue'));
                          } else {
                            return const Center(
                              child: Text('Something Went Wrong...'),
                            );
                          }
                        },
                      )),
                    ],
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
