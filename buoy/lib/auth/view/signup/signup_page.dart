import 'package:buoy/auth/cubit/signup_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Signup extends StatefulWidget {
  final PageController pageController;
  const Signup({required this.pageController, super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool logoClicked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white.withOpacity(0.8)
            : Colors.black.withAlpha(180),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
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
                        'lib/assets/logo/buoy_logo.png',
                        color: Colors.orange[800],
                        width: 52,
                        height: 52,
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
                    SizedBox(
                      height: 80,
                      child: Text(
                        'Buoy',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontFamily: GoogleFonts.corben().fontFamily),
                      ),
                    ),
                  ],
                ),
                const GutterTiny(),
                Text(
                  'Make sure they made it safe.',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Gutter(),
                // FractionallySizedBox(
                //   widthFactor: 0.7,
                //   child: SupaSocialsAuth(
                //     socialProviders: const [
                //       SocialProviders.google,
                //     ],
                //     redirectUrl:
                //         'io.supabase.flutterquickstart://login-callback/',
                //     onSuccess: (p0) {},
                //   ),
                // ),
                BlocBuilder<SignupCubit, SignupState>(
                  builder: (context, state) {
                    if (state.status == SignupStatus.submitting) {
                      return Theme.of(context).brightness == Brightness.dark
                          ? FilledButton(
                              onPressed: () {},
                              child: const CircularProgressIndicator.adaptive())
                          : ElevatedButton(
                              onPressed: () {},
                              child: const CircularProgressIndicator.adaptive());
                    }
                    if (state.status == SignupStatus.failure) {
                      return Theme.of(context).brightness == Brightness.dark
                          ? FilledButton.icon(
                              icon: const Icon(Icons.error),
                              onPressed: () {
                                context.read<SignupCubit>().signupWithGoogle();
                              },
                              label: const Text(
                                'Error! Retry.',
                              ))
                          : ElevatedButton.icon(
                              onPressed: () {
                                context.read<SignupCubit>().signupWithGoogle();
                              },
                              label: const Text('Error! Retry.'),
                              icon: const Icon(Icons.error),
                            );
                    }
                    if (state.status == SignupStatus.success) {
                      return Theme.of(context).brightness == Brightness.dark
                          ? FilledButton.icon(
                              icon: const Icon(Icons.check),
                              onPressed: () {},
                              label: const Text(
                                'Success!',
                              ))
                          : ElevatedButton.icon(
                              onPressed: () {},
                              label: const Text('Success!'),
                              icon: const Icon(Icons.check),
                            );
                    }
                    return Theme.of(context).brightness == Brightness.dark
                        ? FilledButton.icon(
                            onPressed: () {
                              context.read<SignupCubit>().signupWithGoogle();
                            },
                            icon: const Icon(
                              FontAwesomeIcons.google,
                              size: 20.0,
                            ),
                            label: const Text('Sign up with Google'))
                        : ElevatedButton.icon(
                            onPressed: () {
                              context.read<SignupCubit>().signupWithGoogle();
                            },
                            label: const Text('Sign up with Google'),
                            icon: const Icon(
                              FontAwesomeIcons.google,
                              size: 20.0,
                            ),
                          );
                  },
                ),
                TextButton(
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0)),
                    onPressed: () {},
                    child: Text.rich(TextSpan(
                        text: 'Have an account? ',
                        style: Theme.of(context).textTheme.bodyLarge,
                        children: [
                          TextSpan(
                              text: 'Sign in.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary))
                        ])))
              ],
            ),
          ],
        ));
  }
}
