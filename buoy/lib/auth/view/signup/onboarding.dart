import 'package:buoy/auth/view/signup/battery_info_page.dart';
import 'package:buoy/auth/view/signup/privacy_security_page.dart';
import 'package:buoy/auth/view/signup/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
              const BatteryInfoPage(),
              const PrivacySecurityPage(),
            ],
          ),
        ],
      ),
    );
  }
}
