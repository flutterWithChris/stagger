import 'dart:io';

import 'package:buoy/core/constants.dart';
import 'package:buoy/features/auth/presentation/cubit/signup_cubit.dart';
import 'package:buoy/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:buoy/shared/buoy_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

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
        body: Column(
      children: [
        Expanded(
          flex: 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const BuoyLogo(
                size: 40,
              ),
              const GutterLarge(),
              SizedBox(
                height: 280,
                child:
                    Image.asset('lib/assets/graphics/homescreen_highlight.png'),
              ),
              const Gutter(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'Sign in to access all of Stagger\'s features.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Gutter(),
              // FractionallySizedBox(
              //   widthFactor: 0.7,
              //   child: SupaSocialsAuth(
              //     socialProviders: const [OAuthProvider.google],
              //     redirectUrl:
              //         'io.supabase.flutterquickstart://login-callback/',
              //     onSuccess: (p0) {},
              //   ),
              // ),
              BlocConsumer<SignupCubit, SignupState>(
                listener: (context, state) {
                  if (state.status == SignupStatus.success) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(getSuccessSnackbar('Signup success!'));
                    context
                        .read<OnboardingBloc>()
                        .add(StartOnboarding(user: state.user!));
                    context.read<OnboardingBloc>().add(const MoveForward());
                  }
                },
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
                          Platform.isIOS
                              ? context.read<SignupCubit>().signUpWithApple()
                              : context.read<SignupCubit>().signUpWithGoogle();
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.black),
                              
                                  foregroundColor: 
                                  Theme.of(context).brightness == Brightness.dark ? WidgetStatePropertyAll(Colors.white) :
                                  null),
                              onPressed: () {
                                Platform.isIOS
                                    ? context
                                        .read<SignupCubit>()
                                        .signUpWithApple()
                                    : context
                                        .read<SignupCubit>()
                                        .signUpWithGoogle();
                              },
                              icon: Icon(
                                Platform.isIOS
                                    ? FontAwesomeIcons.apple
                                    : FontAwesomeIcons.google,
                                size: 20.0,
                              ),
                              label: Text(Platform.isIOS
                                  ? 'Continue with Apple'
                                  : 'Continue with Google')),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const GutterSmall(),
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
                          context.read<SignupCubit>().signUpWithGoogle();
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
                          'Signup Success!',
                        ));
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                              style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(Color(0xFF4267B2)),
                                  foregroundColor:
                                      WidgetStatePropertyAll(Colors.white)),
                              onPressed: () {
                                context.read<SignupCubit>().signUpWithGoogle();
                              },
                              icon: const Icon(
                                FontAwesomeIcons.facebook,
                                size: 20.0,
                              ),
                              label: const Text('Continue with Facebook')),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const GutterSmall(),

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
                          context.read<SignupCubit>().signUpWithGoogle();
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                      Theme.of(context)
                                          .colorScheme
                                          .tertiaryContainer),
                                  foregroundColor: const WidgetStatePropertyAll(
                                      Colors.white)),
                              onPressed: () {
                                context.read<SignupCubit>().signUpWithGoogle();
                              },
                              icon: const Icon(
                                Icons.email_rounded,
                                size: 20.0,
                              ),
                              label: const Text('Continue with Email')),
                        ),
                      ],
                    ),
                  );
                },
              ),
              TextButton(
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0)),
                  onPressed: () async {
                    await SharedPreferences.getInstance().then((prefs) async {
                      await prefs
                          .setBool('onboardingComplete', true)
                          .then((value) => context.go('/login'));
                    });
                  },
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
        ),
      ],
    ));
  }
}
