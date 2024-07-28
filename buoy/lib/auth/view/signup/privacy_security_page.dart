import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        Icons.security_rounded,
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
                  Text('Privacy & Security',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          fontFamily: GoogleFonts.corben().fontFamily)),
                ],
              ),
              const GutterLarge(),
              Wrap(
                spacing: 8.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 12.0,
                    child: Icon(
                      Icons.location_off_rounded,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      size: 16.0,
                    ),
                  ),
                  Text('Location data is never stored.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w400)),
                ],
              ),
              const Gutter(),
              Wrap(
                spacing: 8.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 12.0,
                    child: Icon(
                      Icons.notification_important_rounded,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      size: 16.0,
                    ),
                  ),
                  Text('Alerts when your location is viewed.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w400)),
                ],
              ),
              const Gutter(),
              Wrap(
                spacing: 8.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 12.0,
                    child: Icon(
                      Icons.tune_rounded,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      size: 16.0,
                    ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36.0),
                child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      fixedSize: const Size(240, 40),
                    ),
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs
                          .setBool('onboardingComplete', true)
                          .then((value) => context.go('/'));
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Finish Setup')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
