import 'package:buoy/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:buoy/features/onboarding/presentation/pages/battery_info_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/bike_type_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/destinations_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/gear_preference_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/join_rides_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/location_permissions.dart';
import 'package:buoy/features/onboarding/presentation/pages/privacy_security_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/ride_buttons_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/ride_style_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/ride_types_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/rider_profile_summary_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/riding_experience_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/safety_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/see_nearby_riders_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/signup_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter/foundation.dart' as foundation;

import 'add_friends_page.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  late PageController pageController;
  int currentPage = 0;
  bool onFirstPage = true;
  @override
  void initState() {
    pageController = context.read<OnboardingBloc>().pageController;
    // TODO: implement initState
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page?.toInt() ?? 0;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
          height: 60,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: (pageController.hasClients &&
                              pageController.page != null &&
                              pageController.page != 0 &&
                              pageController.page! > 1) ==
                          false
                      ? 0.0
                      : 1.0,
                  child: TextButton(
                    onPressed: () async {
                      await pageController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut);
                    },
                    child: Text(
                      'Back',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                // SmoothPageIndicator(
                //   controller: pageController,
                //   count: 11,
                //   effect: WormEffect(
                //     dotColor: Theme.of(context).colorScheme.secondaryContainer,
                //     activeDotColor: Theme.of(context).colorScheme.secondary,
                //     dotHeight: 10,
                //     dotWidth: 10,
                //     //  expansionFactor: 2,
                //     spacing: 5,
                //   ),
                // ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: (pageController.hasClients &&
                              pageController.page != null &&
                              pageController.page != 0 &&
                              pageController.page! > 0) ==
                          false
                      ? 0.0
                      : 1.0,
                  child: FilledButton.tonal(
                    onPressed: () {
                      context.read<OnboardingBloc>().canMoveForward == false
                          ? context
                              .read<OnboardingBloc>()
                              .checkCanMoveForward!()
                          : pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut);
                    },
                    child: Text(
                      'Next',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          )),
      body: Stack(
        children: [
          // Image.asset(
          //   Theme.of(context).brightness == Brightness.light
          //       ? 'lib/assets/backgrounds/light_map_bg.png'
          //       : 'lib/assets/backgrounds/dark_map_bg.png',
          //   fit: BoxFit.cover,
          //   //  color: Colors.black12,
          //   width: double.infinity,
          //   height: double.infinity,
          // ),
          PageView(
            controller: pageController,
            physics: foundation.kReleaseMode == false
                ? null
                : const NeverScrollableScrollPhysics(),
            children: [
              Signup(
                pageController: pageController,
              ),
              const PrivacySecurityPage(),
              const BatteryInfoPage(),
              const RideButtonsPage(),
              const JoinRidesPage(),
              const SeeNearbyRidersPage(),
              const SafetyPage(),
              const RiderProfileSummaryPage(),
              const BikeTypePage(),
              const RidingExperiencePage(),
              const RideStylePage(),
              const GearPreferencePage(),
              const RideTypesPage(),
              const DestinationsPage(),
            ],
          ),
        ],
      ),
    );
  }
}

class DestinationPage {
  const DestinationPage();
}
