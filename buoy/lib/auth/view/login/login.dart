import 'dart:io';

import 'package:buoy/auth/cubit/login_cubit.dart';
import 'package:buoy/shared/buoy_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          // TODO: implement
          if (state is LoginSuccess) {
            context.go('/');
          }
        },
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BuoyLogo(),
            const GutterSmall(),
            Platform.isAndroid
                ? FilledButton.icon(
                    onPressed: () async {
                      await context.read<LoginCubit>().loginWithGoogle();
                    },
                    icon: const Icon(
                      FontAwesomeIcons.google,
                      size: 20.0,
                    ),
                    label: const Text('Login with Google'))
                : FilledButton.icon(
                    onPressed: () async {
                      await context.read<LoginCubit>().loginWithApple();
                    },
                    icon: const Icon(
                      FontAwesomeIcons.apple,
                      size: 20.0,
                    ),
                    label: const Text('Login with Apple')),
            const GutterSmall(),
            TextButton(
                onPressed: () async {
                  await SharedPreferences.getInstance().then((prefs) async {
                    await prefs
                        .setBool('onboardingComplete', false)
                        .then((value) => context.go('/signup'));
                  });
                },
                child: const Text.rich(TextSpan(
                    text: 'Don\'t have an account? ',
                    children: [
                      TextSpan(
                          text: 'Sign up',
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ])))
          ],
        ),
      ),
    );
  }
}
