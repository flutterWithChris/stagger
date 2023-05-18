import 'package:buoy/auth/view/signup/onboarding.dart';
import 'package:buoy/locate/view/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/bloc/auth_bloc.dart';

GoRouter goRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn =
        context.read<AuthBloc>().state.status == AuthStatus.authenticated;
    bool isOnboardingComplete = prefs.getBool('onboardingComplete') ?? false;
    bool isCurrentlyOnboarding = state.location == '/onboarding';
    print('isOnboardingComplete: $isOnboardingComplete');
    print('isLoggedIn: $isLoggedIn');

    if (isOnboardingComplete == false) {
      return '/onboarding';
    }

    if (isLoggedIn) {
    } else {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const Home()),
    GoRoute(
        path: '/onboarding', builder: (context, state) => const Onboarding()),
  ],
);
