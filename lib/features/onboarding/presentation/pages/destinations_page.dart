import 'package:buoy/core/constants.dart';
import 'package:buoy/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:buoy/features/riders/model/rider.dart';
import 'package:buoy/shared/buoy_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DestinationsPage extends StatefulWidget {
  const DestinationsPage({super.key});

  @override
  State<DestinationsPage> createState() => _DestinationsPageState();
}

class _DestinationsPageState extends State<DestinationsPage> {
  final List<RideDestination> _selectedrideDestinations = [];
  @override
  void initState() {
    context.read<OnboardingBloc>().add(SetCanMoveForwardCallback(() {
      if (_selectedrideDestinations.isNotEmpty) {
        context.read<OnboardingBloc>().add(UpdateRider(
            rider: context
                .read<OnboardingBloc>()
                .state
                .rider!
                .copyWith(rideDestinations: _selectedrideDestinations),
            user: context.read<OnboardingBloc>().state.user!));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(getErrorSnackbar(
            'Please select at least one destination to continue.'));
      }
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is OnboardingLoaded) {
          context.read<OnboardingBloc>().add(const MoveForward());
        }
      },
      child: Scaffold(
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
                      child: Text('I often ride to...',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: GoogleFonts.corben().fontFamily)),
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
                              const Text('Select destinations:'),
                              const Gutter(),
                              Wrap(
                                spacing: 8.0,
                                children: [
                                  for (var rideDestination
                                      in RideDestination.values)
                                    ChoiceChip(
                                      label: Text(
                                          rideDestination.name.enumToString()),
                                      selected: _selectedrideDestinations
                                          .contains(rideDestination),
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedrideDestinations
                                                .add(rideDestination);
                                          } else {
                                            _selectedrideDestinations
                                                .remove(rideDestination);
                                          }
                                        });
                                      },
                                    )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // Expanded(
              //     child: Column(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.symmetric(
              //           horizontal: 16.0, vertical: 16.0),
              //       child: Row(
              //         children: [
              //           Expanded(
              //               child: BlocBuilder<OnboardingBloc, OnboardingState>(
              //             builder: (context, state) {
              //               if (state is OnboardingLoading) {
              //                 return const CircularProgressIndicator();
              //               }
              //               if (state is OnboardingError) {
              //                 return Text(state.message);
              //               }
              //               if (state is OnboardingLoaded) {
              //                 return FilledButton(
              //                     onPressed: () {

              //                     },
              //                     child: const Text('Continue'));
              //               } else {
              //                 return const Center(
              //                   child: Text('Something Went Wrong...'),
              //                 );
              //               }
              //             },
              //           )),
              //         ],
              //       ),
              //     )
              //   ],
              // ))
            ],
          ),
        ),
      ),
    );
  }
}
