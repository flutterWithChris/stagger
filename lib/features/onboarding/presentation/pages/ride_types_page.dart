import 'package:buoy/core/constants.dart';
import 'package:buoy/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:buoy/features/riders/model/rider.dart';
import 'package:buoy/shared/buoy_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RideTypesPage extends StatefulWidget {
  const RideTypesPage({super.key});

  @override
  State<RideTypesPage> createState() => _RideTypesPageState();
}

class _RideTypesPageState extends State<RideTypesPage> {
  final List<RideType> _selectedRideTypes = [];
  @override
  void initState() {
    // TODO: implement initState

    context.read<OnboardingBloc>().add(SetCanMoveForwardCallback(() {
      if (_selectedRideTypes.isNotEmpty) {
        context.read<OnboardingBloc>().add(UpdateRider(
            rider: context
                .read<OnboardingBloc>()
                .state
                .rider!
                .copyWith(rideTypes: _selectedRideTypes),
            user: context.read<OnboardingBloc>().state.user!));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(getErrorSnackbar(
            'Please select at least one ride type to continue.'));
      }
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is RiderUpdated) {
          context.read<OnboardingBloc>().add(const MoveForward());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('What kind of rides do you enjoy?',
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
                            const Text('Select ride types:'),
                            const Gutter(),
                            Wrap(
                              spacing: 8.0,
                              children: [
                                for (var rideType in RideType.values)
                                  ChoiceChip(
                                    label: Text(rideType.name.enumToString()),
                                    selected:
                                        _selectedRideTypes.contains(rideType),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedRideTypes.add(rideType);
                                        } else {
                                          _selectedRideTypes.remove(rideType);
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
            ],
          ),
        ),
      ),
    );
  }
}
