import 'package:buoy/core/system/bottom_nav_bar.dart';
import 'package:buoy/core/system/main_sliver_app_bar.dart';
import 'package:buoy/features/locate/bloc/geolocation_bloc.dart';
import 'package:buoy/features/locate/view/map/main_map.dart';
import 'package:buoy/features/profile/repository/bloc/profile_bloc.dart';
import 'package:buoy/features/rides/bloc/ride_bloc.dart';
import 'package:buoy/features/rides/bloc/rides_bloc.dart';
import 'package:buoy/features/rides/model/ride.dart';
import 'package:buoy/core/constants.dart';
import 'package:buoy/shared/presentation/widgets/location_updates_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late final AnimatedMapController mapController =
      AnimatedMapController(vsync: this);

  @override
  Widget build(BuildContext context) {
    return DefaultSheetController(
      child: Scaffold(
        // extendBody: true,
        // extendBodyBehindAppBar: true,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56.0),
            child: AppBar(
              title: Wrap(
                spacing: 16.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/logo/logo_no_bg.png',
                    //  color: Colors.orange[800],
                    width: 26,
                    height: 26,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: BlocBuilder<RideBloc, RideState>(
                      builder: (context, state) {
                        if (state is CreatingRide) {
                          return const Text('Create Ride');
                        }
                        return const Text('Stagger');
                      },
                    ),
                  )
                ],
              ),
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: LocationUpdatesSwitch(),
                ),
                // IconButton(
                //   onPressed: () {},
                //   icon: const Icon(Icons.more_vert),
                // ),
              ],
            )),
        floatingActionButton: BlocBuilder<RidesBloc, RidesState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: state.myRides != null && state.myRides!.isNotEmpty
                      ? 88.0 * state.myRides!.length
                      : 0.0),
              child: FloatingActionButton(
                  child: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold)),
                  onPressed: () {
                    if (state.myRides?.isNotEmpty ?? false) {
                      scaffoldMessengerKey.currentState?.showSnackBar(
                          getErrorSnackbar('You already have an active ride!'));
                      return;
                    }
                    context.read<RideBloc>().add(CreateRide(Ride(
                          senderIds: [
                            context.read<ProfileBloc>().state.user!.id!
                          ],
                        )));
                  }),
            );
          },
        ),
        bottomNavigationBar: const BottomNavBar(),
        body: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            // const MainSliverAppBar(),
            SliverFillRemaining(child: MainMap(mapController: mapController)),
          ],
        ),
      ),
    );
  }
}
