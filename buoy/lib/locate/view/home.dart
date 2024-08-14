import 'package:buoy/core/system/bottom_nav_bar.dart';
import 'package:buoy/core/system/main_sliver_app_bar.dart';
import 'package:buoy/locate/view/map/main_map.dart';
import 'package:buoy/profile/repository/bloc/profile_bloc.dart';
import 'package:buoy/rides/bloc/ride_bloc.dart';
import 'package:buoy/rides/bloc/rides_bloc.dart';
import 'package:buoy/rides/model/ride.dart';
import 'package:buoy/shared/constants.dart';
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
              actions: [
                // IconButton(
                //   onPressed: () async {
                //     showDialog(
                //       context: context,
                //       builder: (context) {
                //         return const AddFriendDialog();
                //       },
                //     );
                //   },
                //   icon: const Icon(Icons.person_add_alt_1_rounded),
                // ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert),
                ),
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
            SliverFillRemaining(
                child: Stack(
              alignment: Alignment.topRight,
              children: [
                MainMap(mapController: mapController),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(50.0),
                      // border: Border.all(color: Colors.white, width: 2.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 32.0,
                          ),
                          // const SizedBox(width: 8.0),
                          // const Text('Location:'),
                          const SizedBox(width: 8.0),
                          Switch(value: true, onChanged: (value) {}),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
