import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:google_fonts/google_fonts.dart';

class JoinRidesPage extends StatelessWidget {
  const JoinRidesPage({super.key});

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
                          Text('Join Rides',
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
                      const Flexible(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8.0,
                          children: [
                            Text(
                              'Rides that others have created will show as a',
                              textAlign: TextAlign.left,
                            ),
                            CircleAvatar(
                                radius: 12,
                                child: Icon(Icons.mode_of_travel_rounded,
                                    size: 16)),
                            Text(
                                'button on the map. Click to see details & join!',
                                textAlign: TextAlign.left),
                          ],
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
