import 'package:buoy/core/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BatteryInfoPage extends StatelessWidget {
  const BatteryInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white.withOpacity(0.8)
          : Colors.black.withAlpha(180),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(36.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Wrap(
                    spacing: 24.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.batteryFull,
                        size: 80,
                        color: Colors.orange[800],
                      ),
                    ],
                  ),
                ],
              ),
              const GutterSmall(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Smart & Battery Efficient',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          fontFamily: GoogleFonts.corben().fontFamily)),
                ],
              ),
              const Gutter(),
              Wrap(
                spacing: 8.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.pause_circle_rounded,
                    color: Colors.orange[800],
                    size: 18.0,
                  ),
                  Text('Auto-pauses when stationary.',
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
                    goRouter.refresh();
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Finish Setup'))
            ],
          ),
        ),
      ),
    );
  }
}
