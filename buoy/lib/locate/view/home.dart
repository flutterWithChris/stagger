import 'package:buoy/core/system/bottom_nav_bar.dart';
import 'package:buoy/core/system/main_sliver_app_bar.dart';
import 'package:buoy/locate/view/map/main_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';

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
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(),
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          MainSliverAppBar(),
          SliverFillRemaining(child: MainMap(mapController: mapController)),
        ],
      ),
    );
  }
}
