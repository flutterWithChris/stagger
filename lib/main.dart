import 'package:buoy/features/activity/bloc/activity_bloc.dart';
import 'package:buoy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:buoy/features/auth/presentation/cubit/login_cubit.dart';
import 'package:buoy/features/auth/presentation/cubit/signup_cubit.dart';
import 'package:buoy/features/auth/data/repository/auth_repository_impl.dart';
import 'package:buoy/config/router/router.dart';
import 'package:buoy/features/friends/bloc/friends_bloc.dart';
import 'package:buoy/features/friends/repository/friend_repository.dart';
import 'package:buoy/features/locate/bloc/geolocation_bloc.dart';
import 'package:buoy/features/locate/repository/background_location_repository.dart';
import 'package:buoy/features/locate/repository/encryption_repository.dart';
import 'package:buoy/features/locate/repository/location_realtime_repository.dart';
import 'package:buoy/features/locate/repository/mapbox_search_repository.dart';
import 'package:buoy/features/locate/repository/public_key_repository.dart';
import 'package:buoy/features/motion/bloc/motion_bloc.dart';
import 'package:buoy/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:buoy/features/profile/repository/bloc/profile_bloc.dart';
import 'package:buoy/features/profile/repository/user_repository.dart';
import 'package:buoy/features/riders/bloc/rider_profile_bloc.dart';
import 'package:buoy/features/riders/bloc/riders_bloc.dart';
import 'package:buoy/features/riders/repo/riders_repository.dart';
import 'package:buoy/features/rides/bloc/ride_bloc.dart';
import 'package:buoy/features/rides/bloc/rides_bloc.dart';
import 'package:buoy/features/rides/repository/ride_repository.dart';
import 'package:buoy/core/constants.dart';
import 'package:buoy/config/theme/theme_cubit.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
      url: dotenv.get('SUPABASE_URL'),
      anonKey: dotenv.get('SUPABASE_PUBLIC_KEY'));
  FlutterSecureStorage storage = const FlutterSecureStorage();
  String? magnolia = await storage.read(key: 'magnolia');
  if (magnolia == null) {
    magnolia = generateRandomKey(32);
    await storage.write(key: 'magnolia', value: magnolia);
  }
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
          create: (context) => AuthRepositoryImpl(),
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
        RepositoryProvider(
          create: (context) => FriendRepository(),
        ),
        RepositoryProvider(
          create: (context) => MapboxSearchRepository(),
        ),
        RepositoryProvider(
          create: (context) => EncryptionRepository(),
        ),
        RepositoryProvider(
          create: (context) => PublicKeyRepository(),
        ),
        RepositoryProvider(
          create: (context) => RideRepository(),
        ),
        RepositoryProvider(
          create: (context) => RidersRepository(),
        )
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => ProfileBloc(
                    userRepository: context.read<UserRepository>(),
                  )),
          BlocProvider(
              create: (context) => AuthBloc(
                  authRepository: context.read<AuthRepositoryImpl>(),
                  profileBloc: context.read<ProfileBloc>())),
          BlocProvider(
              create: (context) => SignupCubit(
                  authRepository: context.read<AuthRepositoryImpl>())),
          BlocProvider(
              create: (context) => LoginCubit(
                  authRepository: context.read<AuthRepositoryImpl>())),
          BlocProvider(
            create: (context) => ThemeCubit()..loadTheme(),
          ),
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
                mapboxSearchRepository: context.read<MapboxSearchRepository>(),
                activityBloc: context.read<ActivityBloc>(),
                backgroundLocationRepository:
                    context.read<BackgroundLocationRepository>(),
                encryptionRepository: context.read<EncryptionRepository>(),
                publicKeyRepository: context.read<PublicKeyRepository>())
              ..add(LoadGeolocation()),
          ),
          BlocProvider(
              create: (context) => FriendsBloc(
                  userRepository: context.read<UserRepository>(),
                  friendRepository: context.read<FriendRepository>())
                ..add(LoadFriends())),
          BlocProvider(
            lazy: false,
            create: (context) => RidesBloc(
              authBloc: context.read<AuthBloc>(),
              rideRepository: context.read<RideRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => RidersBloc(
              ridersRepository: context.read<RidersRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => RiderProfileBloc(),
          ),
          BlocProvider(
            create: (context) => RideBloc(
              mapboxSearchRepository: context.read<MapboxSearchRepository>(),
              rideRepository: context.read<RideRepository>(),
              ridesBloc: context.read<RidesBloc>(),
              ridersBloc: context.read<RidersBloc>(),
            ),
          ),
          BlocProvider(
            create: (context) => OnboardingBloc(
                userRepository: context.read<UserRepository>(),
                ridersRepository: context.read<RidersRepository>()),
          )
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            return MaterialApp.router(
              scaffoldMessengerKey: scaffoldMessengerKey,
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
                    defaultRadius: 14.0,
                    blendTextTheme: true,
                    cardElevation: 0.3,
                    blendOnLevel: 10,
                    blendOnColors: false,
                    useM2StyleDividerInM3: true,
                    adaptiveRadius: FlexAdaptive.all(),
                    elevatedButtonSecondarySchemeColor:
                        SchemeColor.primaryContainer,
                    drawerBackgroundSchemeColor: SchemeColor.surface,
                    popupMenuRadius: 12.0,
                    popupMenuElevation: 0.618,
                    cardRadius: 14.0),
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
                  defaultRadius: 14.0,
                  cardRadius: 22.0,
                  blendTextTheme: true,
                  cardElevation: 0.3,
                  blendOnLevel: 20,
                  useM2StyleDividerInM3: true,
                  adaptiveRadius: FlexAdaptive.all(),
                  elevatedButtonSecondarySchemeColor:
                      SchemeColor.primaryContainer,
                  drawerBackgroundSchemeColor: SchemeColor.surface,
                ),
                useMaterial3ErrorColors: true,
                visualDensity: FlexColorScheme.comfortablePlatformDensity,
                useMaterial3: true,
                fontFamily: GoogleFonts.montserrat().fontFamily,
              ),
              themeMode: state.themeMode ?? ThemeMode.system,
            );
          },
        ),
      ),
    );
  }
}