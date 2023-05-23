import 'package:buoy/activity/bloc/activity_bloc.dart';
import 'package:buoy/auth/bloc/auth_bloc.dart';
import 'package:buoy/auth/cubit/signup_cubit.dart';
import 'package:buoy/auth/repository/auth_repository.dart';
import 'package:buoy/core/router/router.dart';
import 'package:buoy/locate/bloc/geolocation_bloc.dart';
import 'package:buoy/locate/repository/background_location_repository.dart';
import 'package:buoy/locate/repository/location_realtime_repository.dart';
import 'package:buoy/motion/bloc/motion_bloc.dart';
import 'package:buoy/profile/repository/bloc/profile_bloc.dart';
import 'package:buoy/profile/repository/user_repository.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
      url: dotenv.get('SUPABASE_URL'),
      anonKey: dotenv.get('SUPABASE_PUBLIC_KEY'));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider(
          create: (context) => UserRepository(),
        ),
        RepositoryProvider(
          create: (context) => BackgroundLocationRepository(),
        ),
        RepositoryProvider(
          create: (context) => LocationRealtimeRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) =>
                  AuthBloc(authRepository: context.read<AuthRepository>())),
          BlocProvider(
              create: (context) =>
                  SignupCubit(authRepository: context.read<AuthRepository>())),
          BlocProvider(
            create: (context) => MotionBloc(
                backgroundLocationRepository:
                    context.read<BackgroundLocationRepository>()),
          ),
          BlocProvider(
            create: (context) => ActivityBloc(
                backgroundLocationRepository:
                    context.read<BackgroundLocationRepository>()),
          ),
          BlocProvider(
            create: (context) => GeolocationBloc(
                locationRealtimeRepository:
                    context.read<LocationRealtimeRepository>(),
                activityBloc: context.read<ActivityBloc>(),
                motionBloc: context.read<MotionBloc>(),
                backgroundLocationRepository:
                    context.read<BackgroundLocationRepository>())
              ..add(LoadGeolocation()),
          ),
          BlocProvider(
              create: (context) =>
                  ProfileBloc(userRepository: context.read<UserRepository>())
                    ..add(LoadProfile(context.read<AuthBloc>().state.user!.id)))
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routeInformationParser: goRouter.routeInformationParser,
          routerDelegate: goRouter.routerDelegate,
          routeInformationProvider: goRouter.routeInformationProvider,
          title: 'Buoy',
          theme: FlexThemeData.light(
            scheme: FlexScheme.flutterDash,
            surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: 7,
            subThemesData: const FlexSubThemesData(
              blendTextTheme: true,
              cardElevation: 0.3,
              blendOnLevel: 10,
              blendOnColors: false,
              useM2StyleDividerInM3: true,
              adaptiveRadius: FlexAdaptive.all(),
              elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
              drawerBackgroundSchemeColor: SchemeColor.surface,
            ),
            useMaterial3ErrorColors: true,
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
            fontFamily: GoogleFonts.montserrat().fontFamily,
          ),
          darkTheme: FlexThemeData.dark(
            colors: FlexColor
                .schemes[FlexScheme.flutterDash]!.light.defaultError
                .toDark(10, true),
            surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: 13,
            subThemesData: const FlexSubThemesData(
              blendTextTheme: true,
              cardElevation: 0.3,
              blendOnLevel: 20,
              useM2StyleDividerInM3: true,
              adaptiveRadius: FlexAdaptive.all(),
              elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
              drawerBackgroundSchemeColor: SchemeColor.surface,
            ),
            useMaterial3ErrorColors: true,
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
            fontFamily: GoogleFonts.montserrat().fontFamily,
          ),
          themeMode: ThemeMode.system,
        ),
      ),
    );
  }
}
