import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:google_fonts/google_fonts.dart';

class CrossPlatformPage extends StatelessWidget {
  const CrossPlatformPage({super.key});

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
            children: [
              Wrap(
                spacing: 16.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.apple,
                    size: 100,
                    color: Colors.orange[800],
                  ),
                  Text('&',
                      style: TextStyle(
                          fontSize: 48,
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.corben().fontFamily)),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Icon(
                      Icons.android,
                      size: 100,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
              const GutterSmall(),
              Text('Supports iOS & Android',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      fontFamily: GoogleFonts.corben().fontFamily)),
              const Gutter(),
              Text(
                  'Because making sure they\'re safe shouldn\'t depend on their phone.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}
