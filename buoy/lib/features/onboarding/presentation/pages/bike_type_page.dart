import 'package:buoy/core/constants.dart';
import 'package:buoy/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:buoy/features/riders/model/rider.dart';
import 'package:buoy/shared/buoy_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BikeTypePage extends StatefulWidget {
  const BikeTypePage({super.key});

  @override
  State<BikeTypePage> createState() => _BikeTypePageState();
}

class _BikeTypePageState extends State<BikeTypePage> {
  final TextEditingController _bikeModelController = TextEditingController();
  BikeType? _selectedBikeType;
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
                      Text('What Do You Ride?',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: GoogleFonts.corben().fontFamily)),
                      const Gutter(),
                      TextFormField(
                        controller: _bikeModelController,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a bike model' : null,
                        decoration: InputDecoration(
                          labelText: 'Bike Model',
                          hintText: 'Honda CB500X, Yamaha R1, etc.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(36.0),
                          ),
                        ),
                      ),
                      const Gutter(),
                      // Select a bike type dropdown
                      DropdownButtonFormField<BikeType>(
                        onSaved: (bikeType) => _selectedBikeType = bikeType,
                        validator: (value) =>
                            value == null ? 'Please select a bike type' : null,
                        decoration: InputDecoration(
                          labelText: 'Bike Type',
                          hintText: 'Select a bike type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(36.0),
                          ),
                        ),
                        items: BikeType.values
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.name.toString().enumToString()),
                                ))
                            .toList(),
                        onChanged: (value) {},
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(16.0),
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //         // color: Colors.white,
                      //         borderRadius: BorderRadius.circular(36.0),
                      //         border: Border.all(color: Colors.grey[200]!)),
                      //     child: Padding(
                      //       padding: const EdgeInsets.symmetric(
                      //           horizontal: 24.0, vertical: 24.0),
                      //       child: Column(
                      //         mainAxisSize: MainAxisSize.min,
                      //         children: [
                      //           Text('Select a bike type:',
                      //               textAlign: TextAlign.center,
                      //               style: Theme.of(context)
                      //                   .textTheme
                      //                   .titleMedium!
                      //                   .copyWith(
                      //                     fontWeight: FontWeight.bold,
                      //                   )),
                      //           SizedBox(
                      //               height: 200,
                      //               child: ListView.builder(
                      //                   itemCount: BikeType.values.length,
                      //                   // shrinkWrap: true,
                      //                   itemBuilder: (context, index) {
                      //                     return ListTile(
                      //                       leading:
                      //                           Icon(PhosphorIcons.motorcycle()),
                      //                       title: Text(BikeType.values[index].name
                      //                           .toString()
                      //                           .enumToString()),
                      //                       onTap: () {},
                      //                     );
                      //                   })),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // )
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
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();

                                      context.read<OnboardingBloc>().add(
                                          UpdateRider(
                                              user: state.user!,
                                              rider: state.rider!.copyWith(
                                                  bike: _bikeModelController
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
                                                  bike: _bikeModelController
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
