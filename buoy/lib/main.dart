import 'package:buoy/activity/bloc/activity_bloc.dart';
import 'package:buoy/auth/bloc/auth_bloc.dart';
import 'package:buoy/auth/cubit/login_cubit.dart';
import 'package:buoy/auth/cubit/signup_cubit.dart';
import 'package:buoy/auth/repository/auth_repository.dart';
import 'package:buoy/core/router/router.dart';
import 'package:buoy/friends/bloc/friends_bloc.dart';
import 'package:buoy/friends/repository/friend_repository.dart';
import 'package:buoy/locate/bloc/geolocation_bloc.dart';
import 'package:buoy/locate/repository/background_location_repository.dart';
import 'package:buoy/locate/repository/encryption_repository.dart';
import 'package:buoy/locate/repository/location_realtime_repository.dart';
import 'package:buoy/locate/repository/mapbox_search_repository.dart';
import 'package:buoy/locate/repository/public_key_repository.dart';
import 'package:buoy/motion/bloc/motion_bloc.dart';
import 'package:buoy/profile/repository/bloc/profile_bloc.dart';
import 'package:buoy/profile/repository/user_repository.dart';
import 'package:buoy/rides/bloc/ride_bloc.dart';
import 'package:buoy/rides/bloc/rides_bloc.dart';
import 'package:buoy/rides/repository/ride_repository.dart';
import 'package:buoy/shared/constants.dart';
import 'package:buoy/shared/theme/theme_cubit.dart';
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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => ProfileBloc(
                    userRepository: context.read<UserRepository>(),
                  )),
          BlocProvider(
              create: (context) => AuthBloc(
                  authRepository: context.read<AuthRepository>(),
                  profileBloc: context.read<ProfileBloc>())),
          BlocProvider(
              create: (context) =>
                  SignupCubit(authRepository: context.read<AuthRepository>())),
          BlocProvider(
              create: (context) =>
                  LoginCubit(authRepository: context.read<AuthRepository>())),
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
            create: (context) => RideBloc(
              mapboxSearchRepository: context.read<MapboxSearchRepository>(),
              rideRepository: context.read<RideRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => RidesBloc(
              rideRepository: context.read<RideRepository>(),
            )..add(LoadRides()),
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
