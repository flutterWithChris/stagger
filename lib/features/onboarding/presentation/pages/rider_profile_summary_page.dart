import 'package:buoy/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:buoy/shared/buoy_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:google_fonts/google_fonts.dart';

class RiderProfileSummaryPage extends StatefulWidget {
  const RiderProfileSummaryPage({super.key});

  @override
  State<RiderProfileSummaryPage> createState() =>
      _RiderProfileSummaryPageState();
}

class _RiderProfileSummaryPageState extends State<RiderProfileSummaryPage> {
  @override
  void initState() {
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Create your rider profile',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.corben().fontFamily)),
                  const Gutter(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.circular(36.0),
                          border: Border.all(color: Colors.grey[200]!)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60.0, vertical: 24.0),
                        child: Column(
                          children: [
                            const BuoyLogo(iconOnly: true),
                            const Gutter(),
                            Text(
                                'Let\'s start by learning more about how you ride.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600])),
                            const GutterTiny(),
                            TextButton.icon(
                                onPressed: () {},
                                label: const Text('Takes 1 minute'),
                                icon: const Icon(Icons.timer_rounded)),
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
