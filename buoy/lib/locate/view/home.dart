import 'package:buoy/activity/bloc/activity_bloc.dart';
import 'package:buoy/core/system/bottom_nav_bar.dart';
import 'package:buoy/locate/bloc/geolocation_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';

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
          SliverAppBar(
            title: Wrap(
              spacing: 12.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/logo/buoy_logo.png',
                  color: Colors.orange[800],
                  width: 24,
                  height: 24,
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Text('Buoy'),
                )
              ],
            ),
          ),
          SliverFillRemaining(
              child: BlocConsumer<GeolocationBloc, GeolocationState>(
            listener: (context, state) async {
              if (state is GeolocationLoaded || state is GeolocationUpdating) {
                await mapController.animateTo(
                    dest: LatLng(state.location!.coords.latitude,
                        state.location!.coords.longitude));
              }
            },
            builder: (context, state) {
              if (state is GeolocationLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is GeolocationLoaded || state is GeolocationUpdating) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        center: LatLng(state.location!.coords.latitude - 0.16,
                            state.location!.coords.longitude),
                        zoom: 10.0,
                        maxZoom: 18.0,
                        minZoom: 2.0,
                        maxBounds: LatLngBounds(
                            LatLng(-90.0, -180.0), LatLng(90.0, 180.0)),
                        interactiveFlags: InteractiveFlag.pinchZoom |
                            InteractiveFlag.drag |
                            InteractiveFlag.doubleTapZoom |
                            InteractiveFlag.flingAnimation,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              Theme.of(context).brightness == Brightness.light
                                  ? dotenv.get('MAPBOX_API_URL')
                                  : dotenv.get(
                                      'MAPBOX_API_DARK_URL',
                                    ),
                          additionalOptions: {
                            'accessToken': dotenv.get('MAPBOX_MAGNOLIA'),
                            'id': 'mapbox/streets-v11',
                          },
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              anchorPos: AnchorPos.align(AnchorAlign.top),
                              width: 32.0,
                              height: 32.0,
                              point: LatLng(state.location!.coords.latitude,
                                  state.location!.coords.longitude),
                              builder: (ctx) => Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 30.0,
                                    backgroundColor:
                                        Theme.of(context).splashColor,
                                  )
                                      .animate(
                                        onComplete: (controller) =>
                                            controller.repeat(),
                                      )
                                      .fadeIn(duration: 800.ms)
                                      .scale(duration: 1.618.seconds)
                                      .fadeOut(delay: 800.ms),
                                  Icon(
                                    Icons.person_pin_circle_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 30.0,
                                    fill: 1.0,
                                  ),
                                ],
                              ),
                            ),
                            Marker(
                              width: 100.0,
                              height: 100.0,
                              point: LatLng(40.909167, -73.115497),
                              builder: (ctx) => Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 28.0,
                                    backgroundColor:
                                        Theme.of(context).splashColor,
                                  )
                                      .animate(
                                        onComplete: (controller) =>
                                            controller.repeat(),
                                      )
                                      .fadeIn(duration: 800.ms)
                                      .scale(duration: 1.618.seconds)
                                      .fadeOut(delay: 800.ms),
                                  // Kelly
                                  const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 18.0,
                                    child: CircleAvatar(
                                      radius: 16.0,
                                      foregroundImage:
                                          CachedNetworkImageProvider(
                                        'https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/313255261_5446832598772011_8429708394281270457_n.jpg?_nc_cat=111&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=cC1oCE1bZZUAX_G0zMK&_nc_ht=scontent-lga3-1.xx&oh=00_AfDSq3JYCnxKwHfooa2ZAGfBoAklU20kUR-LkcOLb7WqGg&oe=646B1FA2',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Justin
                            Marker(
                              width: 100.0,
                              height: 100.0,
                              point: LatLng(40.905864, -72.743684),
                              builder: (ctx) => Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 28.0,
                                    backgroundColor:
                                        Theme.of(context).splashColor,
                                  )
                                      .animate(
                                        onComplete: (controller) =>
                                            controller.repeat(),
                                      )
                                      .fadeIn(duration: 800.ms)
                                      .scale(duration: 1.618.seconds)
                                      .fadeOut(delay: 800.ms),
                                  const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 18.0,
                                    child: CircleAvatar(
                                      radius: 16.0,
                                      foregroundImage:
                                          CachedNetworkImageProvider(
                                        'https://scontent-ord5-2.xx.fbcdn.net/v/t1.18169-9/26993314_10212996658128798_4595686453243734005_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=DvsvZHhuO-8AX_DksWj&_nc_ht=scontent-ord5-2.xx&oh=00_AfDiQsZAOjjtRHD57wwSRfT_c02Yci30fhFO9kNnuXcENA&oe=647B7F09',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Marker(
                              width: 100.0,
                              height: 100.0,
                              point: LatLng(40.943029, -72.943628),
                              builder: (ctx) => Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 28.0,
                                    backgroundColor:
                                        Theme.of(context).splashColor,
                                  )
                                      .animate(
                                        onComplete: (controller) =>
                                            controller.repeat(),
                                      )
                                      .fadeIn(duration: 800.ms)
                                      .scale(duration: 1.618.seconds)
                                      .fadeOut(delay: 800.ms),
                                  const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 18.0,
                                    child: CircleAvatar(
                                      radius: 16.0,
                                      foregroundImage:
                                          CachedNetworkImageProvider(
                                        'https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/272085883_4774303025995034_4450740488095800449_n.jpg?_nc_cat=100&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=kQdSTUdI0H8AX8sEgKo&_nc_oc=AQk8EegLzHae30h4gNftEhLLr7EuKwc9neu5Z_zcy3oETKCMsbXCOJhh-Gjnvcwv_f46q7y7fW-E6ic-xc7IuiNS&_nc_ht=scontent-lga3-1.xx&oh=00_AfAbOxUsSBbm7noFoWLuxa59KKDMZeu2qqs10qWOAmaxrQ&oe=646B9C1D',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    LayoutBuilder(builder: (context, constraints) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight * 0.5,
                          minHeight: 0,
                          minWidth: constraints.maxWidth,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                          child: CustomScrollView(
                            clipBehavior: Clip.antiAlias,
                            reverse: true,
                            shrinkWrap: true,
                            slivers: [
                              SliverList(
                                delegate: SliverChildListDelegate(
                                  [
                                    FriendLocationCard(
                                        name: 'Justin',
                                        profilePhotoUrl:
                                            'https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/272085883_4774303025995034_4450740488095800449_n.jpg?_nc_cat=100&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=kQdSTUdI0H8AX8sEgKo&_nc_oc=AQk8EegLzHae30h4gNftEhLLr7EuKwc9neu5Z_zcy3oETKCMsbXCOJhh-Gjnvcwv_f46q7y7fW-E6ic-xc7IuiNS&_nc_ht=scontent-lga3-1.xx&oh=00_AfAbOxUsSBbm7noFoWLuxa59KKDMZeu2qqs10qWOAmaxrQ&oe=646B9C1D',
                                        isOnline: false,
                                        location: 'Miller Place, NY',
                                        time: 'Stationary'),
                                    FriendLocationCard(
                                        name: 'Dad',
                                        profilePhotoUrl:
                                            'https://scontent-ord5-2.xx.fbcdn.net/v/t1.18169-9/26993314_10212996658128798_4595686453243734005_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=DvsvZHhuO-8AX_DksWj&_nc_ht=scontent-ord5-2.xx&oh=00_AfDiQsZAOjjtRHD57wwSRfT_c02Yci30fhFO9kNnuXcENA&oe=647B7F09',
                                        isOnline: true,
                                        location: 'Calverton, NY',
                                        time: 'Driving'),
                                    FriendLocationCard(
                                        name: 'Kelly',
                                        profilePhotoUrl:
                                            'https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/313255261_5446832598772011_8429708394281270457_n.jpg?_nc_cat=111&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=cC1oCE1bZZUAX_G0zMK&_nc_ht=scontent-lga3-1.xx&oh=00_AfDSq3JYCnxKwHfooa2ZAGfBoAklU20kUR-LkcOLb7WqGg&oe=646B1FA2',
                                        isOnline: true,
                                        location: 'Old Field, NY',
                                        time: 'Walking'),
                                  ]
                                      .animate(interval: 200.ms)
                                      .fadeIn(
                                        duration: 400.ms,
                                        curve: Curves.easeOutSine,
                                      )
                                      .slideY(
                                        duration: 800.ms,
                                        begin: 18.0,
                                        end: 0.0,
                                        curve: Curves.easeOutQuint,
                                      ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                    Positioned(
                      top: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 60,
                          width: 200,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: CircleAvatar(
                                    radius: 20.0,
                                    foregroundImage: CachedNetworkImageProvider(
                                        'https://scontent-ord5-2.xx.fbcdn.net/v/t1.6435-9/193213907_4419559838077181_2959395753433319266_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=wOk65qwQtM4AX-u5oOI&_nc_ht=scontent-ord5-2.xx&oh=00_AfBfuDGJuqIyOTavFvz2JUa7KosApfemDsxTMOf86LbnUg&oe=647BE024'),
                                  ),
                                ),
                                BlocBuilder<ActivityBloc, ActivityState>(
                                  builder: (context, state) {
                                    if (state is ActivityLoading) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0.0, vertical: 6.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Brookhaven, NY',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge,
                                            ),
                                            Wrap(
                                              spacing: 2.0,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.warning,
                                                  size: 14.0,
                                                ),
                                                Text(
                                                  'Error Detecting Motion',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    }
                                    if (state is ActivityError) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0.0, vertical: 6.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Brookhaven, NY',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall,
                                            ),
                                            Wrap(
                                              spacing: 2.0,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.hiking_rounded,
                                                  size: 14.0,
                                                ),
                                                Text(
                                                  'Walking',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    }
                                    if (state is ActivityLoaded) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0.0, vertical: 10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Brookhaven, NY',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            Wrap(
                                              spacing: 4.0,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                Icon(
                                                  state.activity == 'still'
                                                      ? Icons.pause
                                                      : state.activity ==
                                                                  'on_foot' ||
                                                              state.activity ==
                                                                  'walking'
                                                          ? Icons.hiking_rounded
                                                          : state.activity ==
                                                                  'running'
                                                              ? Icons
                                                                  .directions_run_rounded
                                                              : state.activity ==
                                                                      'in_vehicle'
                                                                  ? Icons
                                                                      .drive_eta_rounded
                                                                  : state.activity ==
                                                                          'on_bicycle'
                                                                      ? Icons
                                                                          .directions_bike_rounded
                                                                      : Icons
                                                                          .error_rounded,
                                                  color: const Color.fromARGB(
                                                      255, 100, 100, 100),
                                                  size: 14.0,
                                                ),
                                                Text(
                                                  state.activity == 'still'
                                                      ? 'Stationary'
                                                      : state.activity ==
                                                                  'on_foot' ||
                                                              state.activity ==
                                                                  'walking'
                                                          ? 'Walking'
                                                          : state.activity ==
                                                                  'running'
                                                              ? 'Running'
                                                              : state.activity ==
                                                                      'in_vehicle'
                                                                  ? 'Driving'
                                                                  : state.activity ==
                                                                          'on_bicycle'
                                                                      ? 'Cycling'
                                                                      : 'Unknown',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    } else {
                                      return const Center(
                                        child: Text('Something Went Wrong...'),
                                      );
                                    }
                                  },
                                )
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(
                                duration: 400.ms,
                                curve: Curves.easeOutSine,
                              )
                              .slideY(
                                duration: 600.ms,
                                begin: -.0,
                                end: 0.0,
                                curve: Curves.easeOutSine,
                              ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              if (state is GeolocationError) {
                return Center(
                  child: Text(state.message),
                );
              } else {
                return const Center(child: Text('Something Went Wrong...'));
              }
            },
          )),
        ],
      ),
    );
  }
}

class FriendLocationCard extends StatelessWidget {
  final bool isOnline;
  final String name;
  String? profilePhotoUrl;
  final String location;
  final String time;
  FriendLocationCard({
    required this.isOnline,
    required this.name,
    this.profilePhotoUrl,
    required this.location,
    required this.time,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {},
        leading: CircleAvatar(
          radius: 22,
          foregroundImage: profilePhotoUrl != null
              ? CachedNetworkImageProvider(profilePhotoUrl!)
              : null,
        ),
        title: Wrap(
          spacing: 6.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(name),
            Icon(
                isOnline
                    ? Icons.share_location_rounded
                    : Icons.location_off_rounded,
                color: isOnline
                    ? Theme.of(context).primaryColor
                    : Colors.grey[500],
                size: isOnline ? 18.0 : 16.0)
          ],
        ),
        subtitle: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6.0,
          children: [
            Text.rich(
              TextSpan(text: location, children: const [
                TextSpan(text: ' • '),
              ]),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(
              height: 30,
              child: FittedBox(
                child: Chip(
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 247, 247, 247),
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: time == 'Walking'
                      ? Theme.of(context).colorScheme.primaryContainer
                      : time == 'Driving'
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : time == 'Stationary'
                              ? Theme.of(context).colorScheme.tertiaryContainer
                              : time == 'Cycling'
                                  ? Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                  : time == 'Running'
                                      ? Theme.of(context)
                                          .colorScheme
                                          .tertiaryContainer
                                      : Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    time,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: time == 'Walking'
                            ? const Color.fromARGB(255, 100, 100, 100)
                            : null),
                  ),
                  avatar: time == 'Walking'
                      ? const Icon(
                          Icons.hiking_rounded,
                          color: Color.fromARGB(255, 100, 100, 100),
                          size: 18.0,
                        )
                      : time == 'Driving'
                          ? const Icon(
                              Icons.drive_eta_rounded,
                              size: 18.0,
                              color: Color.fromARGB(255, 247, 247, 247),
                            )
                          : time == 'Stationary'
                              ? const Icon(Icons.pause,
                                  size: 18.0,
                                  color: Color.fromARGB(255, 247, 247, 247))
                              : time == 'Cycling'
                                  ? Icon(
                                      Icons.directions_bike_rounded,
                                      size: 18.0,
                                      color: Theme.of(context).primaryColor,
                                    )
                                  : time == 'Running'
                                      ? const Icon(
                                          Icons.directions_run_rounded,
                                          size: 18.0,
                                          color: Color.fromARGB(
                                              255, 247, 247, 247),
                                        )
                                      : const SizedBox(),
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
            onPressed: () {}, icon: const Icon(Icons.chevron_right_rounded)),
      ),
    );
  }
}
