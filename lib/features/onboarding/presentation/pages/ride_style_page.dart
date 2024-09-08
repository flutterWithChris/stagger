import 'package:buoy/core/constants.dart';
import 'package:buoy/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:buoy/features/riders/model/rider.dart';
import 'package:buoy/shared/buoy_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RideStylePage extends StatefulWidget {
  const RideStylePage({super.key});

  @override
  State<RideStylePage> createState() => _RideStylePageState();
}

class _RideStylePageState extends State<RideStylePage> {
  RidingStyle? _selectedRidingStyle;
  @override
  void initState() {
    // TODO: implement initState

    context.read<OnboardingBloc>().add(SetCanMoveForwardCallback(() {
      if (_selectedRidingStyle != null) {
        context.read<OnboardingBloc>().add(UpdateRider(
            user: context.read<OnboardingBloc>().state.user!,
            rider: context
                .read<OnboardingBloc>()
                .state
                .rider!
                .copyWith(ridingStyle: _selectedRidingStyle)));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(getErrorSnackbar('Please select a riding style'));
        return false;
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
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('How do you usually ride?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.corben().fontFamily)),
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
                          // border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                shape:
                                    _selectedRidingStyle == RidingStyle.cruiser
                                        ? RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                width: 2))
                                        : null,
                                selectedColor:
                                    Theme.of(context).colorScheme.primary,
                                onTap: () {
                                  setState(() {
                                    _selectedRidingStyle = RidingStyle.cruiser;
                                  });
                                },
                                selected:
                                    _selectedRidingStyle == RidingStyle.cruiser,
                                leading: Icon(PhosphorIcons.mountains(
                                  _selectedRidingStyle == RidingStyle.cruiser
                                      ? PhosphorIconsStyle.fill
                                      : PhosphorIconsStyle.regular,
                                )),
                                title: const Text('Cruisin\' the streets'),
                                subtitle: const Text(
                                    'I like to take it easy and enjoy the scenery.'),
                              ),
                              const Divider(),
                              ListTile(
                                shape:
                                    _selectedRidingStyle == RidingStyle.balanced
                                        ? RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                width: 2))
                                        : null,
                                onTap: () {
                                  setState(() {
                                    _selectedRidingStyle = RidingStyle.balanced;
                                  });
                                },
                                selected: _selectedRidingStyle ==
                                    RidingStyle.balanced,
                                leading: Icon(PhosphorIcons.motorcycle(
                                  _selectedRidingStyle == RidingStyle.balanced
                                      ? PhosphorIconsStyle.fill
                                      : PhosphorIconsStyle.regular,
                                )),
                                title:
                                    const Text('Not too fast, not too slow.'),
                                subtitle: const Text(
                                    'I\'m not afraid to give her some throttle; But safety is paramount.'),
                              ),
                              const Divider(),
                              ListTile(
                                shape: _selectedRidingStyle == RidingStyle.fast
                                    ? RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            width: 2))
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedRidingStyle = RidingStyle.fast;
                                  });
                                },
                                selected:
                                    _selectedRidingStyle == RidingStyle.fast,
                                leading: Icon(PhosphorIcons.flagCheckered(
                                  _selectedRidingStyle == RidingStyle.fast
                                      ? PhosphorIconsStyle.fill
                                      : PhosphorIconsStyle.regular,
                                )),
                                title: const Text('Street Rossi (fast)'),
                                subtitle: const Text(
                                    'Lane splitting is my jam & I might have a radar detector.'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
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
