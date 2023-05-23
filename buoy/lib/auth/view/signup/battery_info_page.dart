import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/router.dart';

class BatteryInfoPage extends StatelessWidget {
  const BatteryInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white.withOpacity(0.8)
          : Colors.black.withAlpha(180),
      body: Center(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('lib/assets/screenshots/friends_screenshot.png'),
              const GutterLarge(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Wrap(
                        spacing: 16.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Icon(
                          //   Icons.battery_full_rounded,
                          //   size: 20.0,
                          //   color: Colors.orange[800],
                          // ),
                          Text('Smart & Battery Efficient',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontFamily:
                                          GoogleFonts.corben().fontFamily)),
                        ],
                      ),
                    ],
                  ),
                  const GutterLarge(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 12.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 12.0,
                            child: Icon(
                              Icons.pause,
                              color: Theme.of(context).scaffoldBackgroundColor,
                              size: 16.0,
                            ),
                          ),
                          Text(
                            'Auto-pauses when stopped.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        ],
                      ),
                      const GutterSmall(),
                      Wrap(
                        spacing: 8.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            Icons.drive_eta_rounded,
                            color: Colors.orange[800],
                            size: 18.0,
                          ),
                          Text('Detects walking, driving, etc.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w400)),
                        ],
                      ),
                      const GutterSmall(),
                      Wrap(
                        spacing: 8.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            color: Colors.orange[800],
                            size: 18.0,
                          ),
                          Text('Custom rules per person.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w400)),
                        ],
                      ),
                      const GutterLarge(),
                      FilledButton.icon(
                          style: FilledButton.styleFrom(
                            fixedSize: const Size(400, 40),
                          ),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool('onboardingComplete', true);
                            goRouter.go('/');
                          },
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: const Text('Finish Setup'))
                    ],
                  ),
                  const GutterLarge(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
