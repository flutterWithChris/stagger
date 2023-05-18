import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
                      const Gutter(),
                      Wrap(
                        spacing: 12.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 12.0,
                            child: Icon(
                              Icons.drive_eta_rounded,
                              color: Theme.of(context).scaffoldBackgroundColor,
                              size: 16.0,
                            ),
                          ),
                          Text('Detects walking, driving, etc.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith()),
                        ],
                      ),
                      const Gutter(),
                      Wrap(
                        spacing: 12.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Platform.isIOS
                              ? CircleAvatar(
                                  radius: 14.0,
                                  child: Icon(
                                    Icons.android,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: 16.0,
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 12.0,
                                  child: Icon(
                                    Icons.apple,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: 16.0,
                                  ),
                                ),
                          Text('Available on iOS & Android.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
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
