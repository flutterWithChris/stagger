import 'package:buoy/auth/view/login/login.dart';
import 'package:buoy/auth/view/signup/onboarding.dart';
import 'package:buoy/friends/view/friend_details.dart';
import 'package:buoy/locate/model/location.dart';
import 'package:buoy/locate/view/home.dart';
import 'package:buoy/profile/view/profile.dart';
import 'package:buoy/riders/profile/rider_profile_page.dart';
import 'package:buoy/settings/view/settings_page.dart';
import 'package:buoy/shared/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/bloc/auth_bloc.dart';

GoRouter goRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.clear();
    bool isLoggedIn =
        context.read<AuthBloc>().state.status == AuthStatus.authenticated;
    bool isOnboardingComplete = prefs.getBool('onboardingComplete') ?? false;
    bool isCurrentlyOnboarding = state.fullPath == '/onboarding';
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
    GoRoute(
      path: '/profile',
      builder: (context, state) => const Profile(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
        path: '/settings', builder: (context, state) => const SettingsPage()),
    GoRoute(
        path: '/friend-details/:id',
        builder: (context, state) {
          final String id = state.pathParameters['id']!;
          return FriendDetailsPage(
            friendId: id,
            location: state.extra as Location,
          );
        }),
    GoRoute(
      path: '/rider-profile/:id',
      builder: (context, state) {
        final String id = state.pathParameters['id']!;
        return const RiderProfilePage();
      },
    ),
  ],
);
