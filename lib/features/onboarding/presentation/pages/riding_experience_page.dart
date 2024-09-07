import 'package:buoy/core/constants.dart';
import 'package:buoy/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:buoy/features/riders/model/rider.dart';
import 'package:buoy/shared/buoy_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RidingExperiencePage extends StatefulWidget {
  const RidingExperiencePage({super.key});

  @override
  State<RidingExperiencePage> createState() => _RidingExperiencePageState();
}

class _RidingExperiencePageState extends State<RidingExperiencePage> {
  final TextEditingController _yearsRidingController = TextEditingController();
  BikeType? _selectedBikeType;
  bool newRider = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('How Long Have You Been Riding?',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: GoogleFonts.corben().fontFamily)),
                      const Gutter(),
                      Row(
                        children: [
                          Checkbox(
                              value: newRider,
                              onChanged: (value) {
                                setState(() {
                                  newRider = value!;
                                });
                              }),
                          const Text('I\'m a New Rider (< 1 year)'),
                        ],
                      ),
                      const Gutter(),
                      TextFormField(
                        enabled: !newRider,
                        controller: _yearsRidingController,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter the amount of years you\'ve been riding'
                            : int.tryParse(value) == null
                                ? 'Please enter a valid, non-decimal number'
                                : null,
                        decoration: InputDecoration(
                          labelText: 'Amount of Years',
                          hintText: '1, 3, 5, etc.',
                          suffixText: 'Years',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(36.0),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                            if (state is OnboardingError) {
                              return FilledButton(
                                  onPressed: () {
                                    if (newRider == true) {
                                      context.read<OnboardingBloc>().add(
                                          UpdateRider(
                                              user: state.user!,
                                              rider: state.rider!
                                                  .copyWith(yearsRiding: 0)));
                                    } else {
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();

                                        context
                                            .read<OnboardingBloc>()
                                            .add(UpdateRider(
                                                user: state.user!,
                                                rider: state.rider!.copyWith(
                                                  yearsRiding: int.parse(
                                                      _yearsRidingController
                                                          .value.text
                                                          .trim()),
                                                )));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(getErrorSnackbar(
                                                'Please enter your riding experience'));
                                      }
                                    }
                                  },
                                  child: const Text('Continue'));
                            } else if (state is OnboardingLoading) {
                              return FilledButton(
                                  onPressed: () {},
                                  child: const CircularProgressIndicator());
                            }
                            if (state is OnboardingLoaded) {
                              return FilledButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();

                                      context.read<OnboardingBloc>().add(
                                          UpdateRider(
                                              user: state.user,
                                              rider: state.rider.copyWith(
                                                  bike: _yearsRidingController
                                                      .text
                                                      .trim(),
                                                  bikeType:
                                                      _selectedBikeType!)));
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(getErrorSnackbar(
                                              'Please enter a bike model & select a bike type'));
                                    }
                                  },
                                  child: const Text('Continue'));
                            } else {
                              return const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Something went wrong'),
                                ],
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
      ),
    );
  }
}
