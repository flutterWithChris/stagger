import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:google_fonts/google_fonts.dart';

class BuoyLogo extends StatefulWidget {
  final double? size;
  final bool? iconOnly;

  const BuoyLogo({this.size, this.iconOnly, super.key});

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
        if (widget.iconOnly == false) const Gutter(),
        if (widget.iconOnly == false)
          Text(
            'Stagger',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: GoogleFonts.inter().fontFamily),
          ),
      ],
    );
  }
}
