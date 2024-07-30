import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:google_fonts/google_fonts.dart';

class BuoyLogo extends StatefulWidget {
  final double? size;

  const BuoyLogo({this.size, super.key});

  @override
  State<BuoyLogo> createState() => _BuoyLogoState();
}

class _BuoyLogoState extends State<BuoyLogo> {
  bool logoClicked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () async {
            setState(() {
              logoClicked = true;
            });
            await Future.delayed(const Duration(milliseconds: 500));
            setState(() {
              logoClicked = false;
            });
          },
          child: Image.asset(
            'lib/assets/logo/logo_no_bg.png',
            // color: Colors.orange[800],
            width: widget.size ?? 52,
            height: widget.size ?? 52,
          )
              .animate(
                onInit: (controller) => controller.forward(),
                target: logoClicked ? 1.0 : 0.0,
              )
              .rotate(
                duration: 400.ms,
                begin: 0.0,
                end: 0.5,
                curve: Curves.easeInOut,
              ),
        ),
        const Gutter(),
        Text(
          'Stagger',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.inter().fontFamily),
        ),
      ],
    );
  }
}
