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
  void initState() {
    // TODO: implement initState
    context.read<OnboardingBloc>().add(SetCanMoveForwardCallback(() {
      if (newRider == true) {
        context.read<OnboardingBloc>().add(UpdateRider(
            user: context.read<OnboardingBloc>().state.user!,
            rider: context.read<OnboardingBloc>().state.rider!.copyWith(
                  yearsRiding: 0,
                )));
      } else {
        if (_formKey.currentState!.validate()) {
          context.read<OnboardingBloc>().add(UpdateRider(
              user: context.read<OnboardingBloc>().state.user!,
              rider: context.read<OnboardingBloc>().state.rider!.copyWith(
                    yearsRiding: newRider
                        ? 0
                        : int.parse(_yearsRidingController.value.text.trim()),
                  )));
        } else {
          return false;
        }
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
                                    fontFamily:
                                        GoogleFonts.corben().fontFamily)),
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
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: true),
                          textInputAction: TextInputAction.done,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
