import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SeeNearbyRidersPage extends StatelessWidget {
  const SeeNearbyRidersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Image.asset(
                    'lib/assets/screenshots/main_map_dark.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gutter(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('See Nearby Riders',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontFamily:
                                          GoogleFonts.corben().fontFamily)),
                        ],
                      ),
                      const Gutter(),
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                              text:
                                  'You can see nearby riders on the map. Marked by a',
                              children: [
                                WidgetSpan(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .tertiaryFixed,
                                        child: Icon(
                                            PhosphorIcons.motorcycle(
                                              PhosphorIconsStyle.fill,
                                            ),
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            size: 16)),
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      'icon. Click to see details (limited for rider safety).',
                                ),
                              ]),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const GutterLarge(),
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