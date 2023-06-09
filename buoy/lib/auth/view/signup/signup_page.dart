import 'package:buoy/auth/cubit/signup_cubit.dart';
import 'package:buoy/shared/buoy_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
                const BuoyLogo(),
                const GutterTiny(),
                Text(
                  'Be sure they made it safe.',
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
                      return FilledButton(
                          onPressed: () {},
                          child: const CircularProgressIndicator.adaptive());
                    }
                    if (state.status == SignupStatus.failure) {
                      return FilledButton.icon(
                          icon: const Icon(Icons.error),
                          onPressed: () {
                            context.read<SignupCubit>().signupWithGoogle();
                          },
                          label: const Text(
                            'Error! Retry.',
                          ));
                    }
                    if (state.status == SignupStatus.success) {
                      return FilledButton.icon(
                          icon: const Icon(Icons.check),
                          onPressed: () {},
                          label: const Text(
                            'Success!',
                          ));
                    }
                    return FilledButton.icon(
                        onPressed: () {
                          context.read<SignupCubit>().signupWithGoogle();
                        },
                        icon: const Icon(
                          FontAwesomeIcons.google,
                          size: 20.0,
                        ),
                        label: const Text('Sign up with Google'));
                  },
                ),
                TextButton(
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0)),
                    onPressed: () {},
                    child: Text.rich(TextSpan(
                        text: 'Have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                              text: 'Sign in.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
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
