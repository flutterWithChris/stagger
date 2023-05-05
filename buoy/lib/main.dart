import 'package:buoy/activity/bloc/activity_bloc.dart';
import 'package:buoy/core/router/router.dart';
import 'package:buoy/locate/bloc/geolocation_bloc.dart';
import 'package:buoy/locate/repository/background_location_repository.dart';
import 'package:buoy/motion/bloc/motion_bloc.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => BackgroundLocationRepository(),
      child: MultiBlocProvider(
        providers: [
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
                activityBloc: context.read<ActivityBloc>(),
                motionBloc: context.read<MotionBloc>(),
                backgroundLocationRepository:
                    context.read<BackgroundLocationRepository>())
              ..add(LoadGeolocation()),
          ),
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

            // fontFamily: GoogleFonts.notoSans().fontFamily,
          ),
          darkTheme: FlexThemeData.dark(
            colors: FlexColor
                .schemes[FlexScheme.flutterDash]!.light.defaultError
                .toDark(10, true),
            surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: 13,
            subThemesData: const FlexSubThemesData(
              blendOnLevel: 20,
              useM2StyleDividerInM3: true,
              adaptiveRadius: FlexAdaptive.all(),
              elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
              drawerBackgroundSchemeColor: SchemeColor.surface,
            ),
            useMaterial3ErrorColors: true,
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
            //   fontFamily: GoogleFonts.notoSans().fontFamily,
          ),
          themeMode: ThemeMode.system,
        ),
      ),
    );
  }
}
