import 'package:buoy/features/onboarding/presentation/pages/battery_info_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/bike_type_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/destinations_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/gear_preference_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/location_permissions.dart';
import 'package:buoy/features/onboarding/presentation/pages/privacy_security_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/ride_style_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/ride_types_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/rider_profile_summary_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/riding_experience_page.dart';
import 'package:buoy/features/onboarding/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'add_friends_page.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  PageController pageController = PageController();
  int currentPage = 0;
  bool onFirstPage = true;
  @override
  void initState() {
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
          color: Theme.of(context).navigationBarTheme.backgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  onPressed: () {
                    pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut);
                  },
                  child: Text(
                    'Back',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              SmoothPageIndicator(
                controller: pageController,
                count: 3,
                effect: WormEffect(
                  dotColor: Theme.of(context).colorScheme.secondaryContainer,
                  activeDotColor: Theme.of(context).colorScheme.secondary,
                  dotHeight: 10,
                  dotWidth: 10,
                  //  expansionFactor: 2,
                  spacing: 5,
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: (pageController.hasClients &&
                            pageController.page != null &&
                            pageController.page != 0 &&
                            pageController.page != 2) ==
                        false
                    ? 0.0
                    : 1.0,
                child: TextButton(
                  onPressed: () {
                    pageController.nextPage(
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
            children: [
              Signup(
                pageController: pageController,
              ),
              const PrivacySecurityPage(),
              const BatteryInfoPage(),
              const RiderProfileSummaryPage(),
              const BikeTypePage(),
              const RidingExperiencePage(),
              const RideStylePage(),
              const GearPreferencePage(),
              const RideTypesPage(),
              const DestinationsPage(),
              const LocationPermissionsPage(),
              const AddFriendsPage(),
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
