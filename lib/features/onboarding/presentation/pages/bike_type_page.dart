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
  void initState() {
    context.read<OnboardingBloc>().add(const SetCanMoveForward(false));
    context.read<OnboardingBloc>().add(SetCanMoveForwardCallback(() => {
          if (_formKey.currentState!.validate())
            {
              context.read<OnboardingBloc>().add(UpdateRider(
                  user: context.read<OnboardingBloc>().state.user!,
                  rider: context.read<OnboardingBloc>().state.rider!.copyWith(
                      bike: _bikeModelController.text.trim(),
                      bikeType: _selectedBikeType!)))
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
        } else if (state is RiderUpdated) {
          context.read<OnboardingBloc>().add(const MoveForward());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
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
                        textCapitalization: TextCapitalization.words,
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
                        onChanged: (bikeType) => setState(() {
                          _selectedBikeType = bikeType!;
                          print('Selected bike type: $_selectedBikeType');
                        }),
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
                      ),
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
